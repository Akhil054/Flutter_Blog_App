part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

final class BlogUpload extends BlogEvent {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<String> topics;

  BlogUpload({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });

}

final class BlogFetchAllBlogs extends BlogEvent {}

/// requests the next page of blogs and appends them to the current list
final class BlogFetchMoreBlogs extends BlogEvent {}

final class BlogToggleLike extends BlogEvent {
  final String blogId;

  BlogToggleLike({required this.blogId});
}

final class BlogUpdate extends BlogEvent {
  final String blogId;
  final String title;
  final String content;
  final List<String> topics;
  final File? newImage;

  BlogUpdate({
    required this.blogId,
    required this.title,
    required this.content,
    required this.topics,
    this.newImage,
  });
}

final class BlogDelete extends BlogEvent {
  final String blogId;

  BlogDelete({required this.blogId});
}
