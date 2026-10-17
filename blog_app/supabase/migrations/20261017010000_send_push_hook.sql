-- Calls the `send-push` edge function for every new notification, so the
-- recipient gets an FCM push while the app is in the background / closed.
--
-- This replaces a dashboard Database Webhook (that UI needs the
-- `supabase_functions` schema, which this project doesn't have). The URL and
-- a shared secret are read from Vault so neither is committed here - create
-- them once per project:
--
--   select vault.create_secret('https://<project-ref>.supabase.co/functions/v1/send-push', 'send_push_url');
--   select vault.create_secret('<random string>', 'send_push_secret');
--
-- and give the function the same secret:
--
--   supabase secrets set SEND_PUSH_SECRET=<random string>

create extension if not exists pg_net with schema extensions;

create or replace function public.call_send_push()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_url    text;
  v_secret text;
begin
  select decrypted_secret into v_url
  from vault.decrypted_secrets where name = 'send_push_url';
  select decrypted_secret into v_secret
  from vault.decrypted_secrets where name = 'send_push_secret';

  -- not configured yet - skip the push rather than fail the like / post
  if v_url is null or v_secret is null then
    return new;
  end if;

  -- pg_net queues the request and sends it after the transaction commits,
  -- so a slow or failing push never holds up the insert
  perform net.http_post(
    url := v_url,
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'notifications',
      'record', to_jsonb(new)
    ),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-webhook-secret', v_secret
    ),
    timeout_milliseconds := 5000
  );

  return new;
exception when others then
  raise warning 'call_send_push failed: %', sqlerrm;
  return new;
end;
$$;

drop trigger if exists on_notification_created on public.notifications;
create trigger on_notification_created
  after insert on public.notifications
  for each row execute function public.call_send_push();
