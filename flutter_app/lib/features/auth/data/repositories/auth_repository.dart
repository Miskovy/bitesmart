import 'package:bite_smart/core/network/api_client.dart';
import 'package:bite_smart/core/services/secure_storage_service.dart';
import 'package:bite_smart/core/utils/jwt_helper.dart';
import 'package:bite_smart/features/auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class IAuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> signup({
    required String fullName,
    required String email,
    required String password,
  });
  Future<void> sendOtp({required String emailOrPhone});
  Future<bool> verifyOtp({required String emailOrPhone, required String otp});
  Future<void> resetPassword({
    required String email,
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
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final responseData = response.data;
      if (responseData != null && responseData['success'] == true) {
        final authData = responseData['data'] as Map<String, dynamic>;
        final token = authData['token'] as String;
        final userMap = authData['user'] as Map<String, dynamic>;

        // Save token securely
        await SecureStorageService.instance.saveToken(token);

        // Extract user details
        final String name = userMap['name'] as String? ?? 'User';
        final String userEmail = userMap['email'] as String? ?? email;
        final String id = JwtHelper.getUserId(token, fallback: 'unknown_id');

        // Cache user details securely for offline access / restoration
        await _secureStorage.write(key: _userEmailKey, value: userEmail);
        await _secureStorage.write(key: _userNameKey, value: name);

        return UserModel(
          id: id,
          email: userEmail,
          displayName: name,
          isEmailVerified: true,
        );
      } else {
        throw Exception(responseData?['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // TODO: Call signup API when available
      return UserModel(
        id: 'user_123',
        email: email,
        displayName: fullName,
        isEmailVerified: false,
      );
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  @override
  Future<void> sendOtp({required String emailOrPhone}) async {
    try {
      // TODO: Call OTP API
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  @override
  Future<bool> verifyOtp({
    required String emailOrPhone,
    required String otp,
  }) async {
    try {
      // TODO: Call OTP verification API
      return true;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      // TODO: Call reset password API
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final hasToken = await SecureStorageService.instance.hasToken();
      if (!hasToken) return null;

      final token = await SecureStorageService.instance.getToken();
      if (token == null) return null;

      final id = JwtHelper.getUserId(token, fallback: 'unknown_id');
      final email = await _secureStorage.read(key: _userEmailKey) ?? '';
      final name = await _secureStorage.read(key: _userNameKey) ?? 'User';

      return UserModel(
        id: id,
        email: email,
        displayName: name,
        isEmailVerified: true,
      );
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
      throw UnimplementedError('Google Sign-In not implemented yet');
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
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
}
