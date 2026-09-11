import 'package:flutter/material.dart';

class BlogEditor extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final void Function(String)? onChanged;
  const BlogEditor({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      /// expands the text field to take all the available space
      maxLines: null,
      onChanged: onChanged,
      validator: (value) {
        if(value!.isEmpty){
          return '$hintText is missing';
        }
        return null;
      },
    );
  }
}
