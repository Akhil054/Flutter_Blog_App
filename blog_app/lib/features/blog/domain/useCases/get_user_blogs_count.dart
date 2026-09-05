import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';
import '../repository/blog_repository.dart';

/// Number of blogs a given user has posted, shown on the profile page.
class GetUserBlogsCount implements UseCase<int, GetUserBlogsCountParams> {
  final BlogRepository blogRepository;
  GetUserBlogsCount(this.blogRepository);

  @override
  Future<Either<Failure, int>> call(GetUserBlogsCountParams params) async {
    return await blogRepository.getUserBlogsCount(params.posterId);
  }
}

class GetUserBlogsCountParams {
  final String posterId;

  const GetUserBlogsCountParams({required this.posterId});
}
