import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Login event
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

// Signup event
class SignupEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final bool agreeToTerms;

  const SignupEvent({
    required this.fullName,
    required this.email,
    required this.password,
    required this.agreeToTerms,
  });

  @override
  List<Object?> get props => [fullName, email, password, agreeToTerms];
}

// Send OTP event
class SendOtpEvent extends AuthEvent {
  final String emailOrPhone;

  const SendOtpEvent({required this.emailOrPhone});

  @override
  List<Object?> get props => [emailOrPhone];
}

// Verify OTP event
class VerifyOtpEvent extends AuthEvent {
  final String emailOrPhone;
  final String otp;

  const VerifyOtpEvent({
    required this.emailOrPhone,
    required this.otp,
  });

  @override
  List<Object?> get props => [emailOrPhone, otp];
}

// Reset password event
class ResetPasswordEvent extends AuthEvent {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordEvent({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [token, newPassword, confirmPassword];
}

// Logout event
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

// Check authentication status event
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

// Google sign-in event
class GoogleSignInEvent extends AuthEvent {
  const GoogleSignInEvent();
}

// Apple sign-in event
class AppleSignInEvent extends AuthEvent {
  const AppleSignInEvent();
}
