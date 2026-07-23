import 'package:blog_app/error/failures.dart';
import 'package:blog_app/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entites/user.dart';
import '../../../../core/usecase/usecase.dart';

/// need to uses an default para coz it was taking an dynamic one
class UserSignUp implements UseCase<User,UserSignUpParams> {
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);

/// is like a box that holds either a Failure (left) OR a Success value (right) — fold lets you handle both cases.
  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) async {
    /// Calling an SignUpWithEmailPassword written in Repo associated with domain side
    return await authRepository.signUpWithEmailPassword(
        name: params.name,
        email: params.email,
        password: params.password
    );
  }
}

class UserSignUpParams{
  final String email;
  final String password;
  final String name;
  UserSignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
}