import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketly/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    test('should return backend message when available', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 400,
        data: {'message': 'Backend error message'},
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      final message = ErrorHandler.getErrorMessage(error);
      expect(message, 'Backend error message');
    });

    test('should return backend error field when message is missing', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 400,
        data: {'error': 'Backend error field'},
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      final message = ErrorHandler.getErrorMessage(error);
      expect(message, 'Backend error field');
    });

    test(
      'should fallback to status code message when backend message is missing',
      () {
        final response = Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
          data: {},
        );
        final error = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: response,
          type: DioExceptionType.badResponse,
        );

        final message = ErrorHandler.getErrorMessage(error);
        expect(message, 'Resource not found.');
      },
    );

    test('should handle non-map data gracefully', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 500,
        data: 'Internal Server Error',
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      final message = ErrorHandler.getErrorMessage(error);
      expect(message, 'Server error. Please try again later.');
    });
  });
}
