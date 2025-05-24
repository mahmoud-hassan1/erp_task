import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthUnverified extends AuthState {
  final User? user;
  AuthUnverified(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
} 
class GetEmailError extends AuthState {
  final String message;
  GetEmailError(this.message);
}

class AuthPasswordResetEmailSent extends AuthState {}