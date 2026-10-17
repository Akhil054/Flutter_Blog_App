import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';
import '../entites/blog.dart';
import '../repository/blog_repository.dart';

/// Fetches one blog by id - used when a new blog arrives over Realtime and
/// when the user opens a blog from a notification.
class GetBlogById implements UseCase<Blog, String> {
  final BlogRepository blogRepository;
  GetBlogById(this.blogRepository);

  @override
  Future<Either<Failure, Blog>> call(String blogId) async {
    return await blogRepository.getBlogById(blogId);
  }
}
