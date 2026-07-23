import 'package:blog_app/repository/auth_repository.dart';

import 'package:fpdart/fpdart.dart';
import '../../../../core/common/entites/user.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';

class CurrentUser implements UseCase<User, NoParams>{

  final AuthRepository authRepository;
  CurrentUser(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {

    return await authRepository.CurrentUser();
  }

}

