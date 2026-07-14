import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/domain/usecases/current_user.dart';
import 'package:blog_app/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/repository/auth_repository.dart';
import 'package:blog_app/secret/app_secrets.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/datasources/auth_remote_data_sources.dart';
import 'data/repositories/auth_repository_imp.dart';
import 'domain/usecases/user_sign_in.dart';
import 'domain/usecases/user_sign_up.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async{
  /// store it into supabase var
  final supabase = await Supabase.initialize(
      url: AppSecrets.supabaseUrl,
      anonKey: AppSecrets.supabaseanonKey
  );
  //// registerFactory is nthg but ServiceLocater creates an new instance of register every time its requested
  //// Its been usefull whenever the type is not meant to shared across application & need to be create as perdemand

  //// registerLazySingleton --> its been used when an ServiceLocator meant to maintain single instance of obj.. throughout the app
  //// it will provide same instance whenever its been demanded..
  serviceLocator.registerLazySingleton(() => supabase.client);

  // Core
  serviceLocator.registerLazySingleton<AppUserCubit>(() => AppUserCubit());

  _initAuth();

}

void _initAuth() {
  /// Register the dependencies for Auth Remote DS & fix manually abt auth_remote_ds as its req by auth_repo_impl
  serviceLocator
  ..registerFactory<AuthRemoteDataSources>(
        () => AuthRemoteDataSourcesImpl(
          serviceLocator(),
        ),
  )

  /// Register the dependencies for Auth Repo Impl
  /// Manually settingup auth repo coz usersignup return is that.. and here we have imnpl that's why..
  ..registerFactory<AuthRepository>(
      () => AuthRepositoryImp(
        serviceLocator(),    //// it automatically finds the authremoteds
      ),
  )

  /// UseCases
  /// Registering the UserSignup
  ..registerFactory(
      () => UserSignUp(serviceLocator(),
      ),
  )

    ..registerFactory(
        () => CurrentUser(serviceLocator(),
        ),
    )
  /// Registering the UserSignup
  ..registerFactory(
      () => UserLogin(serviceLocator(),
      ),
  )

    /// Bloc
  /// Register Auth Bloc
  ..registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator(),
      userLogin: serviceLocator(),
      currentUser: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );





}
