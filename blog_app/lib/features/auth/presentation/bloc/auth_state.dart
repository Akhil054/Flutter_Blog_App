part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess(this.user);
}

/// Emitted after a successful sign up. Deliberately carries no user and
/// never touches [AppUserCubit] - the account was created but the user is
/// not logged in yet, they still need to sign in on the Login page.
final class AuthSignUpSuccess extends AuthState {}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);

}
