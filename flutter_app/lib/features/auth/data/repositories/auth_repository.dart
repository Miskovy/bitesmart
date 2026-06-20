import 'package:bite_smart/core/network/api_client.dart';
import 'package:bite_smart/core/services/secure_storage_service.dart';
import 'package:bite_smart/core/utils/jwt_helper.dart';
import 'package:bite_smart/features/auth/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class IAuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> signup({
    required String fullName,
    required String email,
    required String password,
  });
  Future<void> sendOtp({required String emailOrPhone});
  Future<String> verifyOtp({required String emailOrPhone, required String otp});
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<UserModel> googleSignIn();
  Future<UserModel> appleSignIn();
}

class AuthRepository implements IAuthRepository {
  static const String _userEmailKey = 'cached_user_email';
  static const String _userNameKey = 'cached_user_name';
  static bool _isGoogleSignInInitialized = false;
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw Exception('Email and password are required');
      }

      final response = await ApiClient.instance.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] == true) {
        final authData = responseData['data'] as Map<String, dynamic>;
        final token = authData['token'] as String;
        final userMap = authData['user'] as Map<String, dynamic>;

        // Save token securely
        await SecureStorageService.instance.saveToken(token);

        // Extract user details
        final String name = userMap['name'] as String? ?? 'User';
        final String userEmail = userMap['email'] as String? ?? email;
        final String id =
            userMap['id'] as String? ??
            JwtHelper.getUserId(token, fallback: 'unknown_id');

        // Cache user details securely for offline access / restoration
        await _secureStorage.write(key: _userEmailKey, value: userEmail);
        await _secureStorage.write(key: _userNameKey, value: name);
        await _markEmailAsRegistered(userEmail);

        return UserModel(
          id: id,
          email: userEmail,
          displayName: name,
          isEmailVerified: true,
        );
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<UserModel> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      if (fullName.trim().isEmpty) {
        throw Exception('Full name is required');
      }
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw Exception('Email and password are required');
      }

      final response = await ApiClient.instance.post(
        '/auth/signup',
        data: {'name': fullName, 'email': email, 'password': password},
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] == true) {
        final authData = responseData['data'] as Map<String, dynamic>;
        final token = authData['token'] as String;
        final userMap = authData['user'] as Map<String, dynamic>;

        // Save token securely
        await SecureStorageService.instance.saveToken(token);

        // Extract user details
        final String name = userMap['name'] as String? ?? fullName;
        final String userEmail = userMap['email'] as String? ?? email;
        final String id =
            userMap['id'] as String? ??
            JwtHelper.getUserId(token, fallback: 'unknown_id');

        // Cache user details securely for offline access / restoration
        await _secureStorage.write(key: _userEmailKey, value: userEmail);
        await _secureStorage.write(key: _userNameKey, value: name);
        await _markEmailAsRegistered(userEmail);

        return UserModel(
          id: id,
          email: userEmail,
          displayName: name,
          isEmailVerified: true,
        );
      } else {
        throw Exception(responseData['message'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> sendOtp({required String emailOrPhone}) async {
    final normalized = emailOrPhone.trim().toLowerCase();

    if (normalized.contains('@')) {
      try {
        final checkResponse = await ApiClient.instance.post(
          '/auth/signup',
          data: {
            'name': 'Validation Check',
            'email': normalized,
            'password': 'TempPassword123!',
          },
        );
        final checkData = checkResponse.data as Map<String, dynamic>;
        if (checkData['success'] == true) {
          throw Exception('This account does not exist');
        }
      } catch (e) {
        final errStr = e.toString();
        if (errStr.contains('already exists') || errStr.contains('exists')) {
          // Email exists in database, proceed
        } else {
          if (errStr.contains('This account does not exist')) {
            rethrow;
          }
          throw Exception(errStr.replaceAll('Exception: ', ''));
        }
      }
    }

    // 2. Fire forgot-password API in the background without awaiting it to avoid blocking navigation
    () async {
      try {
        await ApiClient.instance.post(
          '/auth/forgot-password',
          data: {'email': normalized},
        );
      } catch (error) {
        debugPrint('Background forgot-password error: $error');
      }
    }();
  }

  @override
  Future<String> verifyOtp({
    required String emailOrPhone,
    required String otp,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        '/auth/verify-reset-code',
        data: {'code': otp},
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>? ?? {};
        final token = data['token'] as String? ?? '';
        if (token.isNotEmpty) {
          return token;
        }
        if (data['valid'] == true) {
          return otp;
        }
        return otp; // Fallback if success is true but no fields are returned
      } else {
        throw Exception(responseData['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        '/auth/reset-password',
        data: {'token': token, 'newPassword': newPassword},
      );
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final hasToken = await SecureStorageService.instance.hasToken();
      if (!hasToken) return null;

      final token = await SecureStorageService.instance.getToken();
      if (token == null) return null;

      final email = await _secureStorage.read(key: _userEmailKey);
      final name = await _secureStorage.read(key: _userNameKey);
      final id = JwtHelper.getUserId(token, fallback: 'unknown_id');

      if (email != null && name != null) {
        return UserModel(
          id: id,
          email: email,
          displayName: name,
          isEmailVerified: true,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await SecureStorageService.instance.deleteToken();
      await _secureStorage.delete(key: _userEmailKey);
      await _secureStorage.delete(key: _userNameKey);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<UserModel> googleSignIn() async {
    try {
      // Google Sign-In authenticate() is not supported on web in v7+
      if (kIsWeb) {
        throw Exception(
          'Google Sign-In is not supported on web. Please use the mobile app.',
        );
      }

      // Initialize GoogleSignIn singleton once (required in v7+)
      if (!_isGoogleSignInInitialized) {
        try {
          await GoogleSignIn.instance.initialize(
            serverClientId:
                '631866973740-rse08hek68dcrfc0r787rcrmeu335nuv.apps.googleusercontent.com',
          );
        } catch (e) {
          if (e.toString().contains('already been called')) {
            // Ignore if it has already been initialized
          } else {
            rethrow;
          }
        }
        _isGoogleSignInInitialized = true;
      }

      // Authenticate
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Failed to obtain Google ID Token');
      }

      // Send to Backend
      final response = await ApiClient.instance.post(
        '/auth/google',
        data: {'idToken': idToken},
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] == true) {
        final authData = responseData['data'] as Map<String, dynamic>;
        final token = authData['token'] as String;
        final userMap = authData['user'] as Map<String, dynamic>;

        // Save token securely
        await SecureStorageService.instance.saveToken(token);

        // Extract user details
        final String name = userMap['name'] as String? ?? 'User';
        final String userEmail = userMap['email'] as String? ?? '';
        final String id =
            userMap['id'] as String? ??
            JwtHelper.getUserId(token, fallback: 'unknown_id');

        // Cache user details securely for offline access / restoration
        await _secureStorage.write(key: _userEmailKey, value: userEmail);
        await _secureStorage.write(key: _userNameKey, value: name);
        if (userEmail.isNotEmpty) {
          await _markEmailAsRegistered(userEmail);
        }

        return UserModel(
          id: id,
          email: userEmail,
          displayName: name,
          isEmailVerified: true,
        );
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to authenticate with Google',
        );
      }
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('canceled') || errStr.contains('cancelled')) {
        throw Exception('Google Sign-In was cancelled by user');
      }
      if (errStr.contains('sign_in_failed')) {
        throw Exception(
          'Google Sign-In configuration error. Please ensure SHA-1/OAuth IDs are correctly configured.',
        );
      }
      throw Exception(errStr.replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<UserModel> appleSignIn() async {
    try {
      throw UnimplementedError('Apple Sign-In not implemented yet');
    } catch (e) {
      throw Exception('Apple Sign-In failed: $e');
    }
  }
  Future<void> _markEmailAsRegistered(String email) async {
    try {
      final normalized = email.trim().toLowerCase();
      final registeredEmailsStr =
          await _secureStorage.read(key: 'registered_emails') ?? '';
      final registeredEmails = registeredEmailsStr
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
      registeredEmails.add(normalized);
      await _secureStorage.write(
        key: 'registered_emails',
        value: registeredEmails.join(','),
      );
    } catch (_) {}
  }
}
