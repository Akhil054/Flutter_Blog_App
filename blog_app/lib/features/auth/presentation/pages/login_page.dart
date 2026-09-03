import 'package:blog_app/features/auth/presentation/pages/signup_page.dart';
import 'package:blog_app/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../core/common/Widgets/loader.dart';
import '../../../../core/common/Widgets/show_error_dialog.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_field.dart';

class LoginPage extends StatefulWidget {

  /// Route func created for Login Page and used in Sign up
  static Route<void> route() => MaterialPageRoute(
         builder: (context) => const LoginPage(),
  );
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  /// To get an access of text written in filed we are using TextEditingController
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();


  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // /// Here its validate every form field
    // formKey.currentState!.validate();

    return Scaffold(

      /// added the padding so spaces are left form L & R Side
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            /// If it fails to verify (wrong password/username etc.)
            /// show a popup dialog instead of a bottom snack bar
            if(state is AuthFailure){
              showErrorDialog(context, state.message);
            }
          },
          /// Form stays mounted at all times (loading or not) so the entered
          /// text, cursor position and focus are never lost/rebuilt -
          /// a loading overlay is shown on top instead of swapping it out.
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Stack(
              children: [
                AbsorbPointer(
                  absorbing: isLoading,
                  child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sign in ',
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
        
                      AuthField(hintText: 'Email', controller: emailController),
                      const SizedBox(height: 15),
        
                      AuthField(hintText: 'Password', controller: passwordController, isObsecureText: true),
        
                      const SizedBox(height: 15),
        
                      AuthButton(
                        buttonText: 'Sign In',
                        onPressed: () {
                          if(formKey.currentState!.validate()){
                            /// call the login function from auth_bloc.dart file & passing the data..
                            context.read<AuthBloc>().add(
                              AuthLogin(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              ),
                            );
                          }
                        },
                      ),
        
                      const SizedBox(height: 15),
        
                      /// Navigation to Sign Up Page
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                                /// route func created in sign up page
                                SignUpPage.route());
                        },
                        /// Rich text allow to user to write 2 different text on same line
        
                        child: RichText(text: TextSpan(text: "Don't have an account ? ",
                            /// define by Flutter by default
                            style: Theme.of(context).textTheme.titleMedium,
                            children: [
                              TextSpan(text: 'Sign up',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppPalette.gradient2,
                                      fontWeight: FontWeight.bold
                                  ))]
                        ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                if(isLoading)
                  const Positioned.fill(
                    child: Loader(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
