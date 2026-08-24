// ignore_for_file: public_member_api_docs, sort_constructors_first
/// Core Functionality consists of blog fields.
/// This class is used to store blog data in the database.
/// It contains the fields required to create a blog post.
import 'dart:convert';

class Blog {
  final String id;
  final String posterId;
  final String title;
  final String content;
  final String imageUrl;
  final List<String> topics;
  final DateTime updatedAt;
  final String author;

  Blog({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.topics,
    required this.updatedAt,
    this.author = 'Anonymous',
  });



  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'posterId': posterId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'topics': topics,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'author': author,
    };
  }
}
