import 'package:blog_app/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// This Interface methd belong to Domain Side of Repo
abstract interface class AuthRepository {
     Future<Either<Failure,String>> signUpWithEmailPassword({
          required String name,
          required String email,
          required String password,
     });

     Future<Either<Failure,String>> loginWithEmailPassword({
          required String email,
          required String password,
     });

}