import 'package:blog_app/core/common/Widgets/loader.dart';
import 'package:blog_app/core/common/Widgets/show_snakbar.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_Card.dart';
import 'package:blog_app/core/theme/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_new_blog.dart';

class BlogPage extends StatefulWidget {
  ///created an static route will be using in add new bloc page
  static route() => MaterialPageRoute(builder: (context) => const BlogPage());

  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {

  /// Accessing the BlogBloc to fetch all the blogs from the database and display them on the screen
  @override
  void initState(){
    super.initState();
    context.read<BlogBloc>().add(BlogFetchGetAllBlogs());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
          IconButton(onPressed: () {
            Navigator.push(context, AddNewBlog.route());
          }, icon: const Icon(CupertinoIcons.add_circled)),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if(state is BlogFailure){
            showSnackBar(context, state.error); 
          }
        },
        builder: (context, state) {
          if(state is BlogLoading){
            return const Loader();
          }
          if(state is BlogDisplaySuccess){
            return ListView.builder(
              itemCount: state.blogs.length,
              itemBuilder: (context, index){
                final blog = state.blogs[index];
                /// returning the blog card widget which is created in widgets folder
                return BlogCard(
                  blog: blog, 
                  color: index % 2 == 0 ? AppPalette.gradient1
                        :  AppPalette.gradient2,
                );
              },
            );
          }
          return const SizedBox(height: 10);
        },
      ),
    );
  }
}
