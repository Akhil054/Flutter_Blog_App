part of 'blog_bloc.dart';

@immutable
sealed class BlogState {}

final class BlogDisplaySuccess extends BlogState {
  final List<Blog> blogs;
  final bool hasReachedMax;
  final bool isLoadingMore;

  BlogDisplaySuccess(
    this.blogs, {
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });
}

/// introducing loading, failure, and success state
final class BlogInitial extends BlogState {}

final class BlogLoading extends BlogState {}

final class BlogFailure extends BlogState {
  final String error;
  BlogFailure(this.error);
}

final class BlogSuccess extends BlogState {

}
