import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add_new_blog.dart';

class BlogPage extends StatelessWidget {
  ///created an static route will be using in add new bloc page
  static route() => MaterialPageRoute(builder: (context) => const BlogPage());

  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('Blog App'),
        actions:[
          IconButton(onPressed:() {
            Navigator.push(context, AddNewBlog.route());
          }, icon:const Icon(CupertinoIcons.add_circled,)),
        ]
      ),

    );
  }
}