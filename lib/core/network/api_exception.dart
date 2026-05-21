import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;

  factory ApiException.fromDioException(DioException dioException) {
    String message = 'Something went wrong';
    int? statusCode = dioException.response?.statusCode;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please try again.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final responseData = dioException.response?.data;
        if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          message = responseData['message'] as String;
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('error')) {
          message = responseData['error'] as String;
        } else {
          message = 'Received invalid response (${dioException.response?.statusCode})';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      default:
        message = 'Unexpected error occurred. Please try again.';
        break;
    }

    return ApiException(message: message, statusCode: statusCode);
  }
}
