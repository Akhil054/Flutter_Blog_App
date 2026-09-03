import 'package:blog_app/core/common/entites/user.dart';
import 'package:blog_app/error/auth_error_message.dart';
import 'package:blog_app/error/exception.dart';
import 'package:blog_app/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../repository/auth_repository.dart';
import '../datasources/auth_remote_data_sources.dart';

/// AuthRepoImp calls the SignUp & Login from auth_remote_ds.dart file
class AuthRepositoryImp  implements AuthRepository {

  final AuthRemoteDataSources remoteDataSource;
  AuthRepositoryImp(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password
  }) async {
      return _getUser(() async =>  await remoteDataSource.loginWithEmailPassword(
          email: email,
          password: password
        ),
      );
    }


  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password
  }) async {
      return _getUser(() async => await remoteDataSource.signUpWithEmailPassword(
          name: name,
          email: email,
          password: password),
      );
  }

  @override
  Future<Either<Failure, User>> CurrentUser() async {
    try{
      final user = await remoteDataSource.getCurrentUserData();
      if(user == null){
        return left(Failure('User not logged in'));
      }
      return right(user);
    }
    on ServerException catch (e){
      return left(Failure((e.message)));
    }

  }


  /// More cleaner way
  Future<Either<Failure,User>> _getUser(
      Future<User> Function() fn,
      ) async{
        try{
          final user  = await fn();
          return right(user);
          /// Wrote an try-catch excep coz AuthRemoteDS going to throw an ServerExcep so to catch it

          /// wrote as sb.AuthException coz its coming from supa base lib. sb exposes the user class as well as we created one i.e User.
          /// imported the prefixes as  sb..
        } on sb.AuthException catch (e){
          /// never surface the raw supabase message to the UI
          return left(Failure(authErrorMessage(e)));
        }

          on ServerException catch (e){
          return left(Failure(e.message));
        }
      }


  }
