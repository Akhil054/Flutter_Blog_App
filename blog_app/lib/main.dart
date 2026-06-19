import 'package:blog_app/init_depdencies.dart';
import 'package:blog_app/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/presentation/pages/login_page.dart';
import 'package:blog_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() async {
  /// Ensure the binding are initialise correctly
  WidgetsFlutterBinding.ensureInitialized();

  /// calling the init dependecies
   await initDependencies();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => serviceLocator<AuthBloc>(),
      )
    ], 
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blog App',
      theme: AppTheme.darkThemeMode,
      home: const LoginPage(),
    );
  }
}
