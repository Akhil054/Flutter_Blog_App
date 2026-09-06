import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';
import '../entites/blog.dart';
import '../repository/blog_repository.dart';

/// All blogs a given user has posted, shown on the profile page.
class GetUserBlogs implements UseCase<List<Blog>, String> {
  final BlogRepository blogRepository;
  GetUserBlogs(this.blogRepository);

  @override
  Future<Either<Failure, List<Blog>>> call(String posterId) async {
    return await blogRepository.getUserBlogs(posterId);
  }
}
