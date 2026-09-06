import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';
import '../repository/blog_repository.dart';

class DeleteBlog implements UseCase<void, String> {
  final BlogRepository blogRepository;
  DeleteBlog(this.blogRepository);

  @override
  Future<Either<Failure, void>> call(String blogId) async {
    return await blogRepository.deleteBlog(blogId);
  }
}
