import 'dart:async';

import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/cubits/theme/theme_cubit.dart';
import 'package:blog_app/core/services/notification_service.dart';
import 'package:blog_app/features/ai/presentation/cubit/ai_assist_cubit.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:blog_app/features/notifications/presentation/open_notification_blog.dart';
import 'package:blog_app/init_depdencies.dart';
import 'package:blog_app/theme/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/blog/presentation/pages/blog_page.dart';
// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  /// Ensure the binding are initialise correctly
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// Register the background message handler and set up local notifications
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.init();

  /// calling the init dependecies
  await initDependencies();

  /// read the theme the user last picked so the first frame already
  /// renders in it instead of flashing the default and then switching
  final savedThemeMode = await ThemeCubit.loadSavedTheme();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AppUserCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<AuthBloc>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<BlogBloc>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<AiAssistCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<NotificationCubit>(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(savedThemeMode),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  /// lets a tapped push notification open a blog from outside the widget tree
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<String>? _blogTapSubscription;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
    _blogTapSubscription = NotificationService.onBlogTap.listen(_openBlog);
  }

  @override
  void dispose() {
    _blogTapSubscription?.cancel();
    super.dispose();
  }

  void _openBlog(String blogId) {
    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext == null ||
        context.read<AppUserCubit>().state is! AppUserLoggedIn) {
      return;
    }
    openNotificationBlog(navigatorContext, blogId);
  }

  /// start notifications (Realtime + push token) once someone is logged in,
  /// and open the blog if the app was launched by tapping a push
  Future<void> _onAppUserChanged(BuildContext context, AppUserState state) async {
    final notificationCubit = context.read<NotificationCubit>();
    if (state is AppUserLoggedIn) {
      await notificationCubit.start();
      final initialBlogId = await NotificationService.takeInitialBlogId();
      if (initialBlogId != null) {
        /// wait for the home page to be built before pushing on top of it
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _openBlog(initialBlogId));
      }
    } else {
      await notificationCubit.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Blog App',
          theme: AppTheme.lightThemeMode,
          darkTheme: AppTheme.darkThemeMode,
          themeMode: themeMode,
          home: BlocListener<AppUserCubit, AppUserState>(
            listenWhen: (previous, current) =>
                (previous is AppUserLoggedIn) != (current is AppUserLoggedIn),
            listener: _onAppUserChanged,
            child: BlocSelector<AppUserCubit, AppUserState, bool>(
              selector: (state) {
                return state is AppUserLoggedIn;
              },
              builder: (context, isLoggedIn) {
                if (isLoggedIn) {
                  return const BlogPage();
                }

                return const LoginPage();
              },
            ),
          ),
        );
      },
    );
  }
}
