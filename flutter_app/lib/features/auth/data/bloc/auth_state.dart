import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

// Login states
class AuthLoginSuccess extends AuthState {
  final String userId;
  final String email;
  final String? message;

  const AuthLoginSuccess({
    required this.userId,
    required this.email,
    this.message,
  });

  @override
  List<Object?> get props => [userId, email, message];
}

// Signup states
class AuthSignupSuccess extends AuthState {
  final String userId;
  final String email;
  final String? message;

  const AuthSignupSuccess({
    required this.userId,
    required this.email,
    this.message,
  });

  @override
  List<Object?> get props => [userId, email, message];
}

// OTP states
class AuthOtpSent extends AuthState {
  final String email;
  final String? message;

  const AuthOtpSent({
    required this.email,
    this.message,
  });

  @override
  List<Object?> get props => [email, message];
}

class AuthOtpVerified extends AuthState {
  final String email;
  final String? message;

  const AuthOtpVerified({
    required this.email,
    this.message,
  });

  @override
  List<Object?> get props => [email, message];
}

// Password reset states
class AuthPasswordResetSuccess extends AuthState {
  final String? message;

  const AuthPasswordResetSuccess({this.message});

  @override
  List<Object?> get props => [message];
}

// Authenticated state
class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String? displayName;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [userId, email, displayName];
}

// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// Error state
class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}
