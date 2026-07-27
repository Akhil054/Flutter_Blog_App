/// Calling this file will initialize all the dependencies for the app
part of 'init_depdencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async{
  /// store it into supabase var
  final supabase = await Supabase.initialize(
      url: AppSecrets.supabaseUrl,
      // anonKey: AppSecrets.supabaseanonKey
      publishableKey: AppSecrets.publishableKey
  );
  //// registerFactory is nthg but ServiceLocater creates an new instance of register every time its requested
  //// Its been usefull whenever the type is not meant to shared across application & need to be create as perdemand

  //// registerLazySingleton --> its been used when an ServiceLocator meant to maintain single instance of obj.. throughout the app
  //// it will provide same instance whenever its been demanded..
  serviceLocator.registerLazySingleton(() => supabase.client);

  serviceLocator.registerFactory(() => InternetConnection());

  // Core
  serviceLocator.registerLazySingleton<AppUserCubit>(() => AppUserCubit());

  /// doing the interface & passing the impl class to it.. so that we can use the interface in the repo & use the impl class here
  serviceLocator.registerFactory<ConnectionChecker>(
  () => ConnectionCheckerImpl(
    internetConnection: serviceLocator(),
    ),
  );

  _initAuth();

  _initBlog();

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
        serviceLocator(),    //// it automatically finds the connectionchecker
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

void _initBlog() {
  //Datasources
  serviceLocator
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(
        supabaseClient: serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // UseCases
    ..registerFactory(
      () => UploadBlog(
        serviceLocator(),
      ),
    )

    ..registerFactory(
      () => GetAllBlogs(serviceLocator()),
    )

    // Bloc
    ..registerLazySingleton(
      () => BlogBloc(
        /// named arguments are used to avoid confusion as we have multiple usecases in blogbloc
        uploadBlog:serviceLocator(),
        getAllBlogs: serviceLocator(),
      ),
    );
}
