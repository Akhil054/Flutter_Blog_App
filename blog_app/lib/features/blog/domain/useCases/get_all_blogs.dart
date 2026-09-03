import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';
import '../entites/blog.dart';
import '../repository/blog_repository.dart';

class GetAllBlogs implements UseCase<List<Blog>, GetAllBlogsParams> {
  final BlogRepository blogRepository;
  GetAllBlogs(this.blogRepository);

  @override
  Future<Either<Failure, List<Blog>>> call(GetAllBlogsParams params) async {
    return await blogRepository.getAllBlogs(page: params.page, limit: params.limit);
  }
}

class GetAllBlogsParams {
  final int page;
  final int limit;

  const GetAllBlogsParams({required this.page, this.limit = 10});
}
