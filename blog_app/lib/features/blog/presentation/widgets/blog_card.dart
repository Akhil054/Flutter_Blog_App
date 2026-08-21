import 'package:blog_app/features/blog/domain/entites/blog.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_detailPage.dart';
import 'package:blog_app/theme/pallete.dart';
import 'package:flutter/material.dart';

class BlogCard extends StatelessWidget {
  final Blog blog;
  final Color color;

  const BlogCard({
    super.key,
    required this.blog,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(context, BlogDetailpage.route(blog));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    blog.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(height: 180),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    blog.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),

                // const Align(
                //   alignment: Alignment.bottomLeft,
                //   child: Text(
                //     'Tap for More',
                //     style: TextStyle(
                //       fontSize: 14,
                //       color: AppPalette.whiteColor,
                //     ),
                //   ),
                // ),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    blog.topics.isNotEmpty ? blog.topics.first : '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppPalette.whiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
