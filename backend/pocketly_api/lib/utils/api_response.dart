import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// Standard API response format for consistency across all endpoints
class ApiResponse {
  /// Creates a successful response
  static Response success({
    required dynamic data,
    String? message,
    int statusCode = HttpStatus.ok,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'message': message,
        'data': data,
      },
    );
  }

  /// Creates a successful response with a custom message
  static Response successWithMessage({
    required String message,
    dynamic data,
    int statusCode = HttpStatus.ok,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'message': message,
        'data': data,
      },
    );
  }

  /// Creates a created (201) response
  static Response created({
    required dynamic data,
    String? message,
  }) {
    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'success': true,
        'message': message ?? 'Resource created successfully',
        'data': data,
      },
    );
  }

  /// Creates a no content (204) response for successful deletions/updates
  static Response noContent({String? message}) {
    return Response.json(
      body: {
        'success': true,
        'message': message ?? 'Operation completed successfully',
        'data': null,
      },
    );
  }

  /// Creates a bad request (400) response
  static Response badRequest({
    required String message,
    dynamic errors,
  }) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'success': false,
        'message': message,
        'errors': errors,
      },
    );
  }

  /// Creates an unauthorized (401) response
  static Response unauthorized({
    String message = 'Unauthorized',
    dynamic errors,
  }) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {
        'success': false,
        'message': message,
        'errors': errors,
      },
    );
  }

  /// Creates a forbidden (403) response
  static Response forbidden({
    String message = 'Forbidden',
    dynamic errors,
  }) {
    return Response.json(
      statusCode: HttpStatus.forbidden,
      body: {
        'success': false,
        'message': message,
        'errors': errors,
      },
    );
  }

  /// Creates a not found (404) response
  static Response notFound({
    String message = 'Resource not found',
    dynamic errors,
  }) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'success': false,
        'message': message,
        'errors': errors,
      },
    );
  }

  /// Creates a conflict (409) response
  static Response conflict({
    required String message,
    dynamic errors,
  }) {
    return Response.json(
      statusCode: HttpStatus.conflict,
      body: {
        'success': false,
        'message': message,
        'errors': errors,
      },
    );
  }

  /// Creates an internal server error (500) response
  static Response internalError({
    String message = 'An internal error occurred',
    dynamic errors,
  }) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': message,
        'errors': errors,
      },
    );
  }

  /// Creates a method not allowed (405) response
  static Response methodNotAllowed({
    String message = 'Method not allowed',
  }) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'success': false,
        'message': message,
        'errors': null,
      },
    );
  }
}
