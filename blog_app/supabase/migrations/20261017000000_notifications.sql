-- Notifications: "X liked your blog" and "X posted a new blog".
--
-- Rows are written only by the SECURITY DEFINER triggers below, never by
-- the app directly. The app reads them live over Realtime, and a Database
-- Webhook on INSERT calls the `send-push` edge function so the recipient
-- also gets an FCM push when the app is in the background / closed.

-- ---------------------------------------------------------------------------
-- FCM device tokens (one user can be signed in on several devices)
-- ---------------------------------------------------------------------------
create table if not exists public.device_tokens (
  token      text primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  platform   text,
  updated_at timestamptz not null default now()
);

create index if not exists device_tokens_user_id_idx
  on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;

drop policy if exists "Users manage their own device tokens" on public.device_tokens;
create policy "Users manage their own device tokens"
  on public.device_tokens for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- A token moves to whoever signed in on that device last, so let an upsert
-- take over a row another user left behind (the token itself is the secret).
create or replace function public.register_device_token(p_token text, p_platform text)
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.device_tokens (token, user_id, platform, updated_at)
  values (p_token, auth.uid(), p_platform, now())
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        updated_at = now();
$$;

revoke all on function public.register_device_token(text, text) from public, anon;
grant execute on function public.register_device_token(text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- Notifications
-- ---------------------------------------------------------------------------
create table if not exists public.notifications (
  id           uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references auth.users (id) on delete cascade,
  actor_id     uuid references auth.users (id) on delete cascade,
  type         text not null check (type in ('like', 'new_blog')),
  blog_id      uuid references public.blogs (id) on delete cascade,
  title        text not null,
  body         text not null default '',
  is_read      boolean not null default false,
  created_at   timestamptz not null default now()
);

create index if not exists notifications_recipient_created_idx
  on public.notifications (recipient_id, created_at desc);

alter table public.notifications enable row level security;

drop policy if exists "Users read their own notifications" on public.notifications;
create policy "Users read their own notifications"
  on public.notifications for select
  to authenticated
  using (auth.uid() = recipient_id);

drop policy if exists "Users mark their own notifications read" on public.notifications;
create policy "Users mark their own notifications read"
  on public.notifications for update
  to authenticated
  using (auth.uid() = recipient_id)
  with check (auth.uid() = recipient_id);

drop policy if exists "Users delete their own notifications" on public.notifications;
create policy "Users delete their own notifications"
  on public.notifications for delete
  to authenticated
  using (auth.uid() = recipient_id);

-- ---------------------------------------------------------------------------
-- Trigger: someone liked a blog -> notify the blog's author
-- ---------------------------------------------------------------------------
create or replace function public.notify_blog_liked()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner_id   uuid;
  v_blog_title text;
  v_actor_name text;
begin
  select poster_id, title into v_owner_id, v_blog_title
  from public.blogs where id = new.blog_id;

  -- no notification for liking your own blog
  if v_owner_id is null or v_owner_id = new.user_id then
    return new;
  end if;

  select coalesce(name, 'Someone') into v_actor_name
  from public.profiles where id = new.user_id;

  -- like -> unlike -> like shouldn't stack up duplicate notifications
  delete from public.notifications
  where type = 'like'
    and blog_id = new.blog_id
    and actor_id = new.user_id
    and recipient_id = v_owner_id;

  insert into public.notifications (recipient_id, actor_id, type, blog_id, title, body)
  values (
    v_owner_id,
    new.user_id,
    'like',
    new.blog_id,
    coalesce(v_actor_name, 'Someone') || ' liked your blog',
    coalesce(v_blog_title, '')
  );

  return new;
end;
$$;

drop trigger if exists on_blog_liked on public.blog_likes;
create trigger on_blog_liked
  after insert on public.blog_likes
  for each row execute function public.notify_blog_liked();

-- ---------------------------------------------------------------------------
-- Trigger: new blog posted -> notify every other user
-- ---------------------------------------------------------------------------
create or replace function public.notify_new_blog()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_poster_name text;
begin
  select coalesce(name, 'Someone') into v_poster_name
  from public.profiles where id = new.poster_id;

  insert into public.notifications (recipient_id, actor_id, type, blog_id, title, body)
  select
    p.id,
    new.poster_id,
    'new_blog',
    new.id,
    coalesce(v_poster_name, 'Someone') || ' posted a new blog - check it out!',
    coalesce(new.title, '')
  from public.profiles p
  where p.id <> new.poster_id;

  return new;
end;
$$;

drop trigger if exists on_blog_created on public.blogs;
create trigger on_blog_created
  after insert on public.blogs
  for each row execute function public.notify_new_blog();

-- ---------------------------------------------------------------------------
-- Realtime: the app listens for new notifications (bell + in-app banner)
-- and new blogs (auto-refreshing the home feed)
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'notifications'
  ) then
    alter publication supabase_realtime add table public.notifications;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'blogs'
  ) then
    alter publication supabase_realtime add table public.blogs;
  end if;
end;
$$;
