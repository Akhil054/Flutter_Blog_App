import 'package:blog_app/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';

class UserLogOut implements UseCase<bool, NoParams> {
  final AuthRepository authRepository;
  UserLogOut(this.authRepository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await authRepository.logOut();
  }
}
