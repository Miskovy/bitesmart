import 'dart:convert';
import 'package:bite_smart/core/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://bitesmart-production.up.railway.app/api';
  final http.Client _client = http.Client();

  // Private constructor for singleton pattern
  ApiService._privateConstructor();

  // Singleton instance
  static final ApiService instance = ApiService._privateConstructor();

  /// Build headers including the JWT token if available
  Future<Map<String, String>> _getHeaders() async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await SecureStorageService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Process the HTTP response and throw descriptive Exception if status is not successful
  Map<String, dynamic> _processResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final String body = response.body;

    Map<String, dynamic> responseData;
    try {
      responseData = json.decode(body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Server returned invalid JSON format (Status Code: $statusCode)');
    }

    if (statusCode >= 200 && statusCode < 300) {
      return responseData;
    }

    // Attempt to extract backend error message
    String errorMessage = 'Request failed with status code $statusCode';
    if (responseData.containsKey('error')) {
      final errorVal = responseData['error'];
      if (errorVal is Map<String, dynamic> && errorVal.containsKey('message')) {
        errorMessage = errorVal['message'] as String;
      } else if (errorVal is String) {
        errorMessage = errorVal;
      }
    } else if (responseData.containsKey('message')) {
      errorMessage = responseData['message'] as String;
    }

    throw Exception(errorMessage);
  }

  /// Execute a GET request
  Future<Map<String, dynamic>> get(String path) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$path');
      final response = await _client.get(uri, headers: headers);
      return _processResponse(response);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid URL or data format');
      }
      rethrow;
    }
  }

  /// Execute a POST request
  Future<Map<String, dynamic>> post(String path, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$path');
      final body = json.encode(data);
      final response = await _client.post(uri, headers: headers, body: body);
      return _processResponse(response);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid URL or data format');
      }
      rethrow;
    }
  }

  /// Execute a PUT request
  Future<Map<String, dynamic>> put(String path, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$path');
      final body = json.encode(data);
      final response = await _client.put(uri, headers: headers, body: body);
      return _processResponse(response);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid URL or data format');
      }
      rethrow;
    }
  }

  /// Execute a DELETE request
  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$path');
      final response = await _client.delete(uri, headers: headers);
      return _processResponse(response);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid URL or data format');
      }
      rethrow;
    }
  }

  /// Execute a multipart POST request to upload a file
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String fileKey,
    required String filePath,
    Map<String, String>? fields,
  }) async {
    try {
      final token = await SecureStorageService.instance.getToken();
      final uri = Uri.parse('$baseUrl$path');
      final request = http.MultipartRequest('POST', uri);
      
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      request.files.add(await http.MultipartFile.fromPath(fileKey, filePath));
      
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
