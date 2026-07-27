import 'package:blog_app/core/utils/calculate_read_time.dart';
import 'package:blog_app/core/utils/format_date.dart';
import 'package:blog_app/features/blog/domain/entites/blog.dart';
import 'package:blog_app/core/theme/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlogViewPage extends StatelessWidget {
  static route(Blog blog) => MaterialPageRoute(
    builder: (context) => BlogViewPage(
      blog: blog,),
  );

  final Blog blog;

  const BlogViewPage({
    super.key, 
    required this.blog
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    /// wrapped with padding to give some space from the edges of the screen
    /// wrapped with SingleChildScrollView to make the content scrollable
    /// wrapped with Scrollbar to show a scrollbar when the content is scrollable
    body: Scrollbar(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(blog.title,
              style: const TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold
                ),
              ),
            const SizedBox(height: 10),
        
            /// displaying the content of the blog
            Text('By ${blog.posterName ?? 'Unknown'}',
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w500
              ),
            ),
      
            /// showing date and reading time of the blog
            const SizedBox(height: 5),
            Text('${formatDateBydMMMYYY(blog.updatedAt)} . ${calculateReadingTime(blog.content)} min read',
              style: const TextStyle(
                color: AppPalette.greyColor,
                fontSize: 16,
                fontWeight: FontWeight.w500
              ),
            ),
              
            const SizedBox(height: 5),
              
            /// displaying the topics of the blog in chip format
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(blog.imageUrl),
            ),
        
            /// displaying the content of the blog
            const SizedBox(height: 10),
            Text(blog.content, 
              style: const TextStyle(
                fontSize: 16, 
                height:2,
                fontWeight: FontWeight.w500
              ),
            ),
          ],),
        ),
      ),
    )
    );
  }
}