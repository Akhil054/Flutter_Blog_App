part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

/// Recieve the event from UI
final class AuthSignUp extends AuthEvent {
  final String email;
  final String name;
  final String password;

  AuthSignUp({
    required this.email,
    required this.name,
    required this.password
  });
}
// Created an event for login
class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({
    required this.email,
    required this.password
  });
}

final class AuthIsUserLoggedIn extends AuthEvent {

}

/// Fired when the user taps logout
final class AuthLogOut extends AuthEvent {

}
