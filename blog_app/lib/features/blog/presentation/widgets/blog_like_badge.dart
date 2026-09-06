import 'package:flutter/material.dart';
import '../../../../theme/pallete.dart';

/// Heart icon + like count, shared by the full [BlogCard] (list/search) and
/// the compact profile-page tile, so the two screens can't drift apart on
/// how a like is displayed.
///
/// Pass [onTap] to make it interactive (toggles the like); omit it for a
/// read-only display, e.g. on the profile page where you're looking at your
/// own post.
class BlogLikeBadge extends StatelessWidget {
  final int likesCount;
  final bool isLiked;
  final VoidCallback? onTap;
  final Color color;

  const BlogLikeBadge({
    super.key,
    required this.likesCount,
    required this.isLiked,
    this.onTap,
    this.color = AppPalette.whiteColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: isLiked ? Colors.redAccent : color,
        ),
        const SizedBox(width: 4),
        Text(
          '$likesCount',
          style: TextStyle(fontSize: 13, color: color),
        ),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      ),
    );
  }
}
