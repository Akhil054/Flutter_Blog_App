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

/// dedicated states for update/delete, separate from BlogSuccess (which
/// AddNewBlog's listener treats as "go to the blog feed") so a screen
/// listening for one doesn't accidentally react to the other
final class BlogUpdateSuccess extends BlogState {
  final Blog blog;
  BlogUpdateSuccess(this.blog);
}

final class BlogDeleteSuccess extends BlogState {}
