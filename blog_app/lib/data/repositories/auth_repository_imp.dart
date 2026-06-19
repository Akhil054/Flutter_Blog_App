import 'package:blog_app/data/datasources/auth_remote_data_sources.dart';
import 'package:blog_app/error/exception.dart';
import 'package:blog_app/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import '../../repository/auth_repository.dart';

/// AuthRepoImp calls the SignUp & Login from auth_remote_ds.dart file
class AuthRepositoryImp  implements AuthRepository {

  final AuthRemoteDataSources remoteDataSource;
  AuthRepositoryImp(this.remoteDataSource);

  @override

  Future<Either<Failure, String>> loginWithEmailPassword({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password
  }) async {
    try{
      final userId  = await remoteDataSource.signUpWithEmailPassword(
          name: name,
          email: email,
          password: password);

      return right(userId);
      /// Wrote an try-catch excep coz AuthRemoteDS going to throw an ServerExcep so to catch it
    } on ServerException catch (e){
      return left(Failure(e.message));
    }

  }


}