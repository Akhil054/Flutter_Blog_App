import 'package:blog_app/core/common/entites/user.dart';
import 'package:blog_app/core/network/connection_checker.dart';
import 'package:blog_app/error/exception.dart';
import 'package:blog_app/error/failures.dart';
import 'package:blog_app/features/auth/data/model/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../repository/auth_repository.dart';
import '../datasources/auth_remote_data_sources.dart';

/// AuthRepoImp calls the SignUp & Login from auth_remote_ds.dart file
/// Network related class / impl & calling various methods from auth_remote_ds.dart file
class AuthRepositoryImp  implements AuthRepository {
  final AuthRemoteDataSources remoteDataSource;
  final ConnectionChecker connectionChecker;
  AuthRepositoryImp(this.remoteDataSource, this.connectionChecker);



  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password
  }) async {
    /// returing getUser function coz its resuable
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
      if(!await (connectionChecker.isConnected)){
        /// taking the help of session to check if user is logged in or not.. 
        final session =  remoteDataSource.currentUserSession;

        if(session == null){
          return left(Failure('User not logged in'));
        }
        
        /// return user model with user details with it 
        return right(UserModel(
          id: session.user.id, 
          email: session.user.email ?? '', 
          name: '',
        ));
      }
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
          /// Checking the internet connection before making the API call
          if(!await (connectionChecker.isConnected)){
            return left(Failure('No internet connection'));
          }
          final user  = await fn();
          return right(user);
          /// Wrote an try-catch excep coz AuthRemoteDS going to throw an ServerExcep so to catch it

          /// wrote as sb.AuthException coz its coming from supa base lib. sb exposes the user class as well as we created one i.e User.
          /// imported the prefixes as  sb..
        } on sb.AuthException catch (e){
          return left(Failure(e.message));
        }

          on ServerException catch (e){
          return left(Failure(e.message));
        }
      }


  }
