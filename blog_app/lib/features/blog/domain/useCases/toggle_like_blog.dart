import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';
import '../repository/blog_repository.dart';

/// toggles the current user's like on a blog; returns the new liked state
class ToggleLikeBlog implements UseCase<bool, String> {
  final BlogRepository blogRepository;
  ToggleLikeBlog(this.blogRepository);

  @override
  Future<Either<Failure, bool>> call(String blogId) async {
    return await blogRepository.toggleLikeBlog(blogId);
  }
}
