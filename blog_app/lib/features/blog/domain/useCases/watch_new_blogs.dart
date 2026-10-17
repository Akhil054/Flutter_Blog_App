import '../repository/blog_repository.dart';

/// Live stream of ids for blogs other users post, so the home feed can
/// update itself. Not a [UseCase] since it's a stream, not a one-off call.
class WatchNewBlogs {
  final BlogRepository blogRepository;
  WatchNewBlogs(this.blogRepository);

  Stream<String> call() => blogRepository.watchNewBlogIds();
}
