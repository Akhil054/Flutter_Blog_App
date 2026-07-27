import 'package:blog_app/core/utils/calculate_read_time.dart';
import 'package:blog_app/features/blog/domain/entites/blog.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
    return GestureDetector(
      onTap: () {
        /// Navigating to the blog view page and passing the blog entity to it
        Navigator.push(context, BlogViewPage.route(blog));
      },
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(16).copyWith(bottom: 4),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:color,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                /// accessing the topics from blog entity and displaying them in chip format
                  children: blog.topics
                  /// Passing children to row i.e making it Iterable
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.all(6.0),
                        /// GestureDetector to detect tap on chip and add it to selectedToppics list
                        child: Chip(
                          label: Text(e),
                        ),
                      ),
                  ).toList(),
              ),
            ),
            Text(blog.title, 
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold
              ),
            ),
            /// displaying the reading time of the blog by calling the calculateReadingTime function from utils folder
          Text('${calculateReadingTime(blog.content)} min '),
          ],
        ),
      ),
    );
  }
}