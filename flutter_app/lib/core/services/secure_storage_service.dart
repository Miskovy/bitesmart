import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _tokenKey = 'auth_token';

  // Memory cache for token to avoid platform channel deadlocks in interceptors
  String? _cachedToken;

  // Instantiate storage with encrypted options for Android and default key chain for iOS
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Private constructor for singleton pattern
  SecureStorageService._privateConstructor();

  // Singleton instance
  static final SecureStorageService instance = SecureStorageService._privateConstructor();

  /// Pre-loads the token from storage (call this in main.dart)
  Future<void> initialize() async {
    try {
      _cachedToken = await _storage.read(key: _tokenKey);
    } catch (_) {
      _cachedToken = null;
    }
  }

  /// Saves the token securely
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the token securely
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    try {
      _cachedToken = await _storage.read(key: _tokenKey);
    } catch (_) {
      _cachedToken = null;
    }
    return _cachedToken;
  }

  /// Deletes the token securely (on logout)
  Future<void> deleteToken() async {
    _cachedToken = null;
    await _storage.delete(key: _tokenKey);
  }

  /// Checks if a token exists in secure storage
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
