/// converts blog object to/from JSON for database storage.
import 'dart:convert';

import '../domain/entites/blog.dart';

class BlogModel extends Blog{

  BlogModel({
    required super.id,
    required super.posterId,
    required super.title,
    required super.content,
    required super.imageUrl,
    required super.topics,
    required super.updatedAt,
    super.author,
    super.likesCount,
    super.isLiked,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'poster_id': posterId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'topics': topics,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BlogModel.fromJson(Map<String, dynamic> map) {
    return BlogModel(
      id: map['id'] as String? ?? '',
      posterId: map['poster_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      topics: List<String>.from((map['topics'] ?? [])),
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  BlogModel copyWith({
    String? id,
    String? posterId,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? topics,
    DateTime? updatedAt,
    String? author,
    int? likesCount,
    bool? isLiked,
  }) {
    return BlogModel(
      id: id ?? this.id,
      posterId: posterId ?? this.posterId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      topics: topics ?? this.topics,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  String toJsonString() => json.encode(toMap());

  factory BlogModel.fromJsonString(String source) =>
      BlogModel.fromJson(json.decode(source) as Map<String, dynamic>);
}
