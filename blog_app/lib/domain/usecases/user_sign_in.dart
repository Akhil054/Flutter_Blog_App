import 'package:blog_app/core/usecase/usecase.dart';
import 'package:blog_app/error/failures.dart';
import 'package:blog_app/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/common/entites/user.dart';

class UserLogin implements UseCase<User, UserLoginParams> {
  final AuthRepository authRepository;
  const UserLogin(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserLoginParams params) async {
    /// return repository login method here 
    /// Calling the loginWithEmailPassword method from auth_repository.dart file
    return await authRepository.loginWithEmailPassword(
      email: params.email,
      password: params.password
    );
  }
}

class UserLoginParams {
  final String email;
  final String password;

  UserLoginParams({
    required this.email,
    required this.password,
  });
}
