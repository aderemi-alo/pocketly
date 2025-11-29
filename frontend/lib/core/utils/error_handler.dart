import 'dart:async';
import 'dart:io';
import 'package:pocketly/core/services/logger_service.dart';
import 'package:dio/dio.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    } else if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is TimeoutException) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }

  static String _handleDioError(DioException error) {
    // Try to extract backend error message
    if (error.response?.data != null) {
      try {
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('message')) {
            return data['message'].toString();
          }
          if (data.containsKey('error')) {
            return data['error'].toString();
          }
        }
      } catch (e) {
        // Fallback to default handling if parsing fails
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return 'Your session has expired. Please log in again.';
        } else if (statusCode == 403) {
          return 'Access denied. Please verify your email.';
        } else if (statusCode == 404) {
          return 'Resource not found.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        } else if (statusCode == 503) {
          return 'Service temporarily unavailable. Please try again later.';
        }
        return 'Server error (${statusCode ?? 'unknown'}). Please try again.';

      case DioExceptionType.cancel:
        return 'Request cancelled.';

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return 'No internet connection. Please check your network.';
        }
        return 'Network error. Please check your connection.';

      default:
        return 'An error occurred. Please try again.';
    }
  }

  static void logError(
    String context,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    AppLogger.error('$context: ${getErrorMessage(error)}', error, stackTrace);
  }
}
