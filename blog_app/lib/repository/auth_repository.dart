import 'package:blog_app/error/failures.dart';
import 'package:fpdart/fpdart.dart';

import '../core/common/entites/user.dart';

/// This Interface methd belong to Domain Side of Repo
abstract interface class AuthRepository {
     Future<Either<Failure,User>> signUpWithEmailPassword({
          required String name,
          required String email,
          required String password,
     });

     Future<Either<Failure,User>> loginWithEmailPassword({
          required String email,
          required String password,
     });

    /// This method is used to check if the user is already logged in or not
     Future<Either<Failure, User>> CurrentUser();

     /// Ends the current session
     Future<Either<Failure, bool>> logOut();

}