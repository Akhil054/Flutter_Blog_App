// ignore_for_file: public_member_api_docs, sort_constructors_first
/// Core Functionality consists of blog fields.
/// This class is used to store blog data in the database.
/// It contains the fields required to create a blog post.
class Blog {
  final String id;
  final String posterId;
  final String title;
  final String content;
  final String imageUrl;
  final List<String> topics;
  final DateTime updatedAt;
  final String author;
  final int likesCount;
  final bool isLiked;

  Blog({
    required this.id,
    required this.posterId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.topics,
    required this.updatedAt,
    this.author = 'Anonymous',
    this.likesCount = 0,
    this.isLiked = false,
  });

  Blog copyWith({
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
    return Blog(
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
      'likesCount': likesCount,
      'isLiked': isLiked,
    };
  }
}
