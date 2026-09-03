import 'package:blog_app/error/auth_error_message.dart';
import 'package:blog_app/error/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/user_model.dart';

/// This interface belongs to Data Sources & we are only concern abt calls made to external data sources

abstract interface class AuthRemoteDataSources {
  Session? get currentUserSession;

  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  /// Login Method
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel?> getCurrentUserData();

  /// Ends the current supabase session
  Future<void> logout();
}
/// depending on datasource i.e supabase
class AuthRemoteDataSourcesImpl implements AuthRemoteDataSources {
  /// Ask supabase client from  imp constructor
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourcesImpl(this.supabaseClient);

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      /// written as final response coz signUp is Future type
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw const ServerException('Invalid email or password.');
      }
      /// not null returning the user id..
      /// get an raw data & converting them into model using fromJson
      return UserModel.fromJson(response.user!.toJson());
    } on ServerException {
      rethrow;
    } catch (e) {
      /// Map raw errors (AuthApiException etc.) to a user friendly message
      throw ServerException(authErrorMessage(e));
    }
  }

  @override
  // TODO: implement currentUserSession
  Session? get currentUserSession => supabaseClient.auth.currentSession;


  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
  /// When an above method is called it should create an user in supbase
    try {
      print('DEBUG: calling supabase signUp with email=$email');
      /// written as final response coz signUp is Future type
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        /// additional data is passed
        data: {
          'name': name,
        },
      );
      print('DEBUG: supabase response user=${response.user?.id}');
      if (response.user == null) {
        /// Custom exception
        throw const ServerException('Could not create your account. Please try again.');
      }

      /// Insert the user's name and email into the public 'users' table
      /// so the profile data is visible in your database
      print('DEBUG: inserting into users table');
      await supabaseClient.from('users').insert({
        'id': response.user!.id,
        'name': name,
        'email': email,
      });
      print('DEBUG: insert into users table success');

      /// not null returning the user id..
      return UserModel.fromJson(response.user!.toJson());
    } on ServerException {
      rethrow;
    } catch (e) {
      print('DEBUG: signup exception: $e');
      /// Map raw errors (AuthApiException etc.) to a user friendly message
      throw ServerException(authErrorMessage(e));
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try{
      if(currentUserSession != null) {
        /// contacting with database & getting the id and current user's session id
        final userData = await supabaseClient.from('profiles').select().eq(
          'id',
          currentUserSession!.user.id,
        );
        return UserModel.fromJson(userData.first);
      }
      return null;
    }
    on ServerException {
      rethrow;
    }
    catch (e) {
      throw ServerException(authErrorMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException(authErrorMessage(e));
    }
  }



}
