import 'package:supabase_flutter/supabase_flutter.dart';

/// Converts raw / internal errors (Supabase [AuthException], Postgrest errors,
/// generic exceptions, etc.) into short, user friendly messages.
///
/// Internal details like "AuthApiException(message: ..., statusCode: 400,
/// code: invalid_credentials)" must never reach the UI.
String authErrorMessage(Object error) {
  if (error is AuthException) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'Invalid email or password.';
      case 'email_not_confirmed':
        return 'Please confirm your email before signing in.';
      case 'user_already_exists':
      case 'email_exists':
        return 'An account with this email already exists.';
      case 'weak_password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'validation_failed':
        return 'Please enter a valid email and password.';
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Too many attempts. Please try again later.';
    }

    /// Older responses may not carry a [code] - fall back to matching the text.
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    return 'Unable to sign you in. Please try again.';
  }

  /// Anything else (network, Postgrest, null user, unexpected) -> stay generic.
  return 'Something went wrong. Please try again.';
}
