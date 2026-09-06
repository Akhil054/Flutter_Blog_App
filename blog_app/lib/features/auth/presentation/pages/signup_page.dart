import 'package:blog_app/core/common/Widgets/show_snakbar.dart';
import 'package:blog_app/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/Widgets/loader.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_field.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {

  /// created an route function in signup page and used in login page..
  static route() => MaterialPageRoute(
      builder: (context) => const SignUpPage(),
  );

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  /// To get an access of text written in filed we are using TextEditingController
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();


  @override
  void dispose(){
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // /// Here its validate every form field
    // formKey.currentState!.validate();

    return Scaffold(
        appBar:AppBar(),
        /// added the padding so spaces are left form L & R Side
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            /// If its fail to  verify it shows an bottom snack bar
            if(state is AuthFailure){
              showSnackBar(context, state.message);
            }
            /// Account created successfully - the user is deliberately NOT
            /// logged in yet (see AuthBloc._onAuthSignUp), so send them back
            /// to the Login page to sign in themselves.
            if(state is AuthSignUpSuccess){
              showSnackBar(context, 'Account created! Please sign in.');
              Navigator.pop(context);
            }
          },
          /// check if the state is loading then show the loader else show the form
          builder: (context, state) {
            if(state is AuthLoading){
              return const Loader();
            }
            return Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sign Up ',
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                  
                      AuthField(hintText: 'Name',controller: nameController),
                      const SizedBox(height: 15),
                  
                       AuthField(hintText: 'Email', controller: emailController),
                      const SizedBox(height: 15),
                  
                      AuthField(hintText: 'Password', controller: passwordController, isObsecureText: true),
        
                      /// Sign Up Button
                      const SizedBox(height: 15),
                      AuthButton(buttonText: 'Sign Up',
                      onPressed: () {
                        print('DEBUG: Sign Up button pressed');
                        /// validating the data..
                        if(formKey.currentState!.validate()){
                          print('DEBUG: form valid, dispatching event');
                          ///calling auth sign up event on auth bloc
                          context.read<AuthBloc>().add(
                              AuthSignUp(
                                  email: emailController.text.trim(),
                                  name: nameController.text.trim(),
                                  password: passwordController.text.trim(),
                              ),
                          );
                        } else {
                          print('DEBUG: form INVALID');
                        }
                      },
                      ),
                  
                      const SizedBox(height: 15),
                  
                  
                      /// Rich text allow to user to write 2 different text on same line
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            LoginPage.route(),
                          );
                        },
                        child: RichText(text: TextSpan(text: "Already have an account ? ",
                            /// define by Flutter by default
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          TextSpan(text: 'Sign In',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              /// see the same swap in login_page.dart's "Sign
                              /// up" link - gradient1 disappears against the
                              /// dark theme's near-black background
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? AppPalette.gradient2
                                  : AppPalette.gradient1,
                              fontWeight: FontWeight.w600,
                            ),)]
                        ),
                        ),
                      ),
                    ],
                  ),
                );
          },
        ),
      ),
    );
  }
}
