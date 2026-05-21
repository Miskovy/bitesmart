import 'dart:convert';

class JwtHelper {
  /// Decodes the payload of a JWT token and returns it as a Map.
  /// Returns null if the token is invalid or parsing fails.
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      
      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      final decodedString = utf8.decode(base64Url.decode(normalized));
      return json.decode(decodedString) as Map<String, dynamic>;
    } catch (e) {
      // In a real application, you might want to log this error
      return null;
    }
  }

  /// Extracts the user ID from the JWT token.
  /// Returns a fallback value (e.g. empty string) if not found or token is invalid.
  static String getUserId(String token, {String fallback = ''}) {
    final decoded = decode(token);
    if (decoded != null && decoded.containsKey('id')) {
      return decoded['id'] as String;
    }
    return fallback;
  }
}
