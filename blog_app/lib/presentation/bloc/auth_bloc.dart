import 'package:blog_app/domain/usecases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'auth_event.dart';
part 'auth_state.dart';

/// Auth Bloc handles an event i.e calls the usecase
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// created an private var
  final UserSignUp _userSignUp;
  AuthBloc({
    required UserSignUp userSignUp,
  }) : _userSignUp = userSignUp, super(AuthInitial()) {
     on<AuthSignUp>((event, emit) async {
       print('DEBUG: AuthSignUp event received: ${event.email}');
       /// auth sign up event recieve then call the usecase
       final res = await _userSignUp(
         UserSignUpParams(
           email: event.email,
           password: event.password,
           name: event.name,
         ),
       );
       print('DEBUG: signup result: $res');
       res.fold(
         (l) {
           print('DEBUG: signup FAILED: ${l.message}');
           emit(AuthFailure(l.message));
         },
         (r) {
           print('DEBUG: signup SUCCESS uid=$r');
           emit(AuthSuccess(r));
         },
       );
     });
  }
}
