import 'package:blog_app/core/common/cubits/theme/theme_cubit.dart';
import 'package:blog_app/features/blog/domain/entites/blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/blog_bloc.dart';
import '../widgets/blog_like_badge.dart';

class BlogDetailpage extends StatefulWidget {
  static route(Blog blog) => MaterialPageRoute(
        builder: (context) => BlogDetailpage(blog: blog),
      );

  final Blog blog;

  const BlogDetailpage({super.key, required this.blog});

  @override
  State<BlogDetailpage> createState() => _BlogDetailpageState();
}

class _BlogDetailpageState extends State<BlogDetailpage> {
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

    return Scaffold(
      appBar: AppBar(
        actions: [
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
    );
  }
}
