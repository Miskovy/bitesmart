import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_event.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_state.dart';
import 'package:bite_smart/features/auth/data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<SignupEvent>(_onSignupEvent);
    on<SendOtpEvent>(_onSendOtpEvent);
    on<VerifyOtpEvent>(_onVerifyOtpEvent);
    on<ResetPasswordEvent>(_onResetPasswordEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<CheckAuthStatusEvent>(_onCheckAuthStatusEvent);
    on<GoogleSignInEvent>(_onGoogleSignInEvent);
    on<AppleSignInEvent>(_onAppleSignInEvent);
  }

  // Handle login
  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthLoginSuccess(
        userId: user.id,
        email: user.email,
        message: 'Login successful',
      ));
      emit(AuthAuthenticated(
        userId: user.id,
        email: user.email,
        displayName: user.displayName,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Handle signup
  Future<void> _onSignupEvent(SignupEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.signup(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
      );
      emit(AuthSignupSuccess(
        userId: user.id,
        email: user.email,
        message: 'Signup successful',
      ));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Handle send OTP
  Future<void> _onSendOtpEvent(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.sendOtp(emailOrPhone: event.emailOrPhone);
      emit(AuthOtpSent(
        email: event.emailOrPhone,
        message: 'OTP sent successfully',
      ));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Handle verify OTP
  Future<void> _onVerifyOtpEvent(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final token = await authRepository.verifyOtp(
        emailOrPhone: event.emailOrPhone,
        otp: event.otp,
      );
      if (token.isNotEmpty) {
        emit(AuthOtpVerified(
          email: event.emailOrPhone,
          message: 'OTP verified successfully',
          token: token,
        ));
      } else {
        emit(const AuthError(message: 'OTP verification failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Handle reset password
  Future<void> _onResetPasswordEvent(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      if (event.newPassword != event.confirmPassword) {
        emit(const AuthError(message: 'Passwords do not match'));
        return;
      }
      await authRepository.resetPassword(
        token: event.token,
        newPassword: event.newPassword,
      );
      emit(AuthPasswordResetSuccess(
        message: 'Password reset successfully',
      ));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Handle logout
  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Handle check auth status
  Future<void> _onCheckAuthStatusEvent(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(
          userId: user.id,
          email: user.email,
          displayName: user.displayName,
        ));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  // Handle Google Sign-In
  Future<void> _onGoogleSignInEvent(
    GoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.googleSignIn();
      emit(AuthAuthenticated(
        userId: user.id,
        email: user.email,
        displayName: user.displayName,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Handle Apple Sign-In
  Future<void> _onAppleSignInEvent(
    AppleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.appleSignIn();
      emit(AuthAuthenticated(
        userId: user.id,
        email: user.email,
        displayName: user.displayName,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
