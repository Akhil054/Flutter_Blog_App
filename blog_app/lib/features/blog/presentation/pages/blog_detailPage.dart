import 'package:blog_app/core/common/cubits/theme/theme_cubit.dart';
import 'package:blog_app/features/blog/domain/entites/blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blog Detail Page"),
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
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text(
              widget.blog.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16.0),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.blog.imageUrl,
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
              ),
            ),

            const SizedBox(height: 20.0),
            Text( 
              "Content: ${widget.blog.content}",
              style: const TextStyle(fontSize: 16.0),
            )
          ]
        )

      )
    );
  }
}
