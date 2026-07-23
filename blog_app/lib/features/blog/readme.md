How Everything Connects

- AddNewBlog collects user input and sends BlogUpload to BlogBloc .
- BlogBloc calls the UploadBlog use case.
- UploadBlog calls the BlogRepository contract.
- BlogRepositoryImpl performs the real work using BlogRemoteDataSource .
- BlogRemoteDataSourceImpl talks to Supabase Storage and Supabase Database.
- BlogModel converts the blog object into JSON format suitable for Supabase.
Dependency Setup

- Dependency registration is done in init_depdencies.dart
- Blog dependencies are connected in this order:
  - BlogRemoteDataSourceImpl gets SupabaseClient
  - BlogRepositoryImpl gets BlogRemoteDataSource
  - UploadBlog gets BlogRepository
  - BlogBloc gets UploadBlog
- These are provided app-wide from main.dart
Simple Flow

- User enters blog data in AddNewBlog
- Screen gets current user ID from AppUserCubit
- Screen sends BlogUpload
- Bloc calls use case
- Use case calls repository
- Repository creates model
- Repository uploads image
- Repository gets public URL
- Repository saves full blog row in blogs table
- Bloc returns success/failure to UI
What Each Layer Takes

- presentation takes raw user input.
- domain takes structured params and defines rules/contracts.
- data takes those params and turns them into Supabase operations.
- Supabase finally stores:
  - image in storage bucket
  - blog data in blogs table