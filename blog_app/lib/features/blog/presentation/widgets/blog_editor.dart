import 'package:flutter/material.dart';

class BlogEditor extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  const BlogEditor({super.key, this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      /// expands the text field to take all the available space
      maxLines: null,
      validator: (value) {
        if(value!.isEmpty){
          return '$hintText is missing';
        }
        return null;
      },
    );
  }
}
