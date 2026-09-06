import 'package:blog_app/core/common/Widgets/show_snakbar.dart';
import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/cubits/theme/theme_cubit.dart';
import 'package:blog_app/features/blog/domain/entites/blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blog_bloc.dart';
import '../widgets/blog_like_badge.dart';
import 'add_new_blog.dart';

class BlogDetailpage extends StatefulWidget {
  static route(Blog blog, {VoidCallback? onChanged}) => MaterialPageRoute(
        builder: (context) => BlogDetailpage(blog: blog, onChanged: onChanged),
      );

  final Blog blog;

  /// Called after a successful edit or delete, so a caller with its own
  /// list of this blog (e.g. the profile page) knows to refresh - deleting
  /// also pops this page back to that caller.
  final VoidCallback? onChanged;

  const BlogDetailpage({super.key, required this.blog, this.onChanged});

  @override
  State<BlogDetailpage> createState() => _BlogDetailpageState();
}

class _BlogDetailpageState extends State<BlogDetailpage> {
  /// Set after a successful edit (the updated row returned by AddNewBlog),
  /// taking priority over both widget.blog and the BlogBloc lookup below -
  /// needed because a user's own blog is never in BlogBloc's list (the main
  /// feed excludes your own posts), so there'd otherwise be nothing to
  /// refresh this page's display with.
  Blog? _localOverride;

  Future<void> _delete(BuildContext context, Blog blog) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete blog?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<BlogBloc>().add(BlogDelete(blogId: blog.id));
    }
  }

  Future<void> _edit(BuildContext context, Blog blog) async {
    final updated = await Navigator.push<Blog>(
      context,
      AddNewBlog.route(blog: blog),
    );
    if (updated != null && mounted) {
      setState(() => _localOverride = updated);
      widget.onChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    /// widget.blog is just a snapshot from whichever list this page was
    /// opened from - look up the live copy in BlogBloc's state (by id) so a
    /// like toggled here reflects immediately, falling back to the snapshot
    /// if the bloc hasn't got this blog loaded (e.g. it's not on the
    /// currently-loaded page of the list).
    final blogState = context.watch<BlogBloc>().state;
    var blog = widget.blog;
    if (blogState is BlogDisplaySuccess) {
      /// blogState.blogs is declared List<Blog> but is actually backed by a
      /// List<BlogModel> at runtime (built via .toList() in the data
      /// source), so firstWhere's generic binds to BlogModel unless we
      /// re-view it as a proper Iterable<Blog> first via .cast() - otherwise
      /// the orElse closure below (typed () => Blog) fails a runtime check.
      blog = blogState.blogs.cast<Blog>().firstWhere(
        (b) => b.id == widget.blog.id,
        orElse: () => widget.blog,
      );
    }
    if (_localOverride != null) blog = _localOverride!;

    final userState = context.watch<AppUserCubit>().state;
    final isOwner = userState is AppUserLoggedIn && userState.user.id == blog.posterId;

    return BlocListener<BlogBloc, BlogState>(
      listener: (context, state) {
        if (state is BlogFailure) {
          showSnackBar(context, state.error);
        }
        if (state is BlogDeleteSuccess) {
          widget.onChanged?.call();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (isOwner) ...[
              IconButton(
                onPressed: () => _edit(context, blog),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () => _delete(context, blog),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
            IconButton(
              icon: Icon(
                context.watch<ThemeCubit>().state == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blog.title,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'by ${blog.author}',
                style: TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),

              const SizedBox(height: 16.0),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  blog.imageUrl,
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlogLikeBadge(
                    likesCount: blog.likesCount,
                    isLiked: blog.isLiked,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                    onTap: () => context.read<BlogBloc>().add(
                          BlogToggleLike(blogId: blog.id),
                        ),
                  ),
                  if (blog.topics.isNotEmpty)
                    Text(
                      blog.topics.first,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20.0),
              Text(
                blog.content,
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
