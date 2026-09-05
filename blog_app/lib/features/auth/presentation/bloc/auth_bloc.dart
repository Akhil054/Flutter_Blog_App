import 'package:blog_app/core/usecase/usecase.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/entites/user.dart';
import '../../domain/usecases/current_user.dart';
import '../../domain/usecases/user_log_out.dart';
import '../../domain/usecases/user_sign_in.dart';
import '../../domain/usecases/user_sign_up.dart';


part 'auth_event.dart';
part 'auth_state.dart';

/// Auth Bloc handles an event i.e calls the usecase
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// created an private var
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final UserLogOut _userLogOut;
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required UserLogOut userLogOut,
    required AppUserCubit appUserCubit,
  }) : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser =  currentUser,
        _userLogOut = userLogOut,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
          on<AuthEvent>((_, emit) => emit(AuthLoading()));
        on<AuthSignUp>(_onAuthSignUp);
        on<AuthLogin>(_onAuthLogin);
        on<AuthIsUserLoggedIn>(_isUserLoggedIn);
        on<AuthLogOut>(_onAuthLogOut);

      }

      /// UserLoggedIn event is called when the app is opened and check if the user is already logged in or not
      void _isUserLoggedIn(
          AuthIsUserLoggedIn event,
          Emitter<AuthState> emit
          ) async{
        /// calling current user class
        final res = await  _currentUser(NoParams());
        res.fold((l) => emit(AuthFailure(l.message)),
              (r) => _emitAuthSuccess(r, emit),

        );
      }
    
    void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
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
      await res.fold(
        (failure) async {
          print('DEBUG: signup FAILED: ${failure.message}');
          emit(AuthFailure(failure.message));
        },
        (user) async {
          print('DEBUG: signup SUCCESS uid=$user');
          /// Sign up must NOT log the user straight into the app - Supabase's
          /// signUp() call opens a live session on the client as soon as it
          /// returns (when email confirmation is off), so sign that session
          /// back out immediately and leave AppUserCubit logged-out. The
          /// user then lands back on the Login page and has to sign in like
          /// anyone else, instead of skipping straight to the blog feed.
          await _userLogOut(NoParams());
          emit(AuthSignUpSuccess());
        },
      );
    }


    void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
      print('DEBUG: AuthLogin event received: ${event.email}');

      /// auth login event recieve then call the usecase
      final res = await _userLogin(UserLoginParams(
        email: event.email,
        password: event.password
      ),);
      res.fold(
        (l) {
          print('DEBUG: login FAILED: ${l.message}');
          emit(AuthFailure(l.message));
        },
        (r) => _emitAuthSuccess(r, emit),
      );
    }

    void _emitAuthSuccess(User user, Emitter<AuthState> emit)
    {
      _appUserCubit.updateUser(user);
      emit(AuthSuccess(user));
    }

    void _onAuthLogOut(AuthLogOut event, Emitter<AuthState> emit) async {
      /// ends the supabase session
      final res = await _userLogOut(NoParams());
      res.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) {
          /// AppUserCubit flipping to logged-out makes MaterialApp's home
          /// swap back to LoginPage in place - no route is pushed here so
          /// there's nothing left on the back stack to return to.
          _appUserCubit.updateUser(null);
          emit(AuthInitial());
        },
      );
    }
}
