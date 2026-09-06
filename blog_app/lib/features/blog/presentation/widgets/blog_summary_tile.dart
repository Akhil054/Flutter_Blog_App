import 'package:flutter/material.dart';
import '../../../../theme/pallete.dart';
import '../../domain/entites/blog.dart';
import '../pages/blog_detailPage.dart';
import 'blog_like_badge.dart';

/// Compact, read-only summary of a blog: title + like count only - no
/// image, author or topics. Used on the profile page's "Your blogs" list,
/// where the full [BlogCard] would be redundant (the author is always the
/// current user there).
class BlogSummaryTile extends StatelessWidget {
  final Blog blog;

  /// Called after this blog is edited or deleted from the detail page, so
  /// the list showing this tile (the profile page) can refresh itself.
  final VoidCallback? onChanged;

  const BlogSummaryTile({super.key, required this.blog, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          /// same border style as the "Blogs posted" count card, so the
          /// two sit consistently on the profile page
          color: Theme.of(context).brightness == Brightness.dark
              ? AppPalette.borderColor
              : AppPalette.lightBorderColor,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Text(
          blog.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: BlogLikeBadge(
          likesCount: blog.likesCount,
          isLiked: blog.isLiked,
          color: textColor ?? Colors.grey,
        ),
        onTap: () => Navigator.push(
          context,
          BlogDetailpage.route(blog, onChanged: onChanged),
        ),
      ),
    );
  }
}
