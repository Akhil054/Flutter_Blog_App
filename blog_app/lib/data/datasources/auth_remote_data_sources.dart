import 'package:blog_app/error/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// This interface belongs to Data Sources & we are only concern abt calls made to external data sources

abstract interface class AuthRemoteDataSources {
  Future<String> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  /// Login Method
  Future<String> loginWithEmailPassword({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourcesImpl implements AuthRemoteDataSources {

  /// Ask supabase client from  imp constructor
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourcesImpl(this.supabaseClient);


  @override
  Future<String> loginWithEmailPassword({
    required String email,
    required String password}) {
    // TODO: implement loginWithEmailPassword
    throw UnimplementedError();
  }

  @override
  Future<String> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password
  }) async {
  /// When an above method is called it should create an user in supbase
    try{
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
      if(response.user == null)
      {
        /// Custom exception
        throw const ServerException('User is null');
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
      return response.user!.id;
    } catch (e){
      print('DEBUG: signup exception: $e');
      throw ServerException(e.toString());
    }

  }
  
}