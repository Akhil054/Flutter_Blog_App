part of 'blog_bloc.dart';

@immutable
sealed class BlogState {}

/// introducing loading, failure, and success state
final class BlogInitial extends BlogState {}

final class BlogLoading extends BlogState {}

final class BlogFailure extends BlogState {
  final String error;
  BlogFailure(this.error);
}

final class BlogUploadSuccess extends BlogState {
  final Blog blog;
  BlogUploadSuccess(this.blog);
}

final class BlogDisplaySuccess extends BlogState {
  final List<Blog> blogs;
  BlogDisplaySuccess(this.blogs);

}
