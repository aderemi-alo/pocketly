// ignore_for_file: public_member_api_docs

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pocketly_api/utils/utils.dart';

Middleware requireAuth() {
  return (handler) {
    return (context) async {
      try {
        final authHeader = context.request.headers['authorization'];
        if (authHeader == null || !authHeader.startsWith('Bearer ')) {
          return ApiResponse.unauthorized(
            message: 'Authorization token required',
          );
        }

        final token = authHeader.substring(7);
        final payload = Encryption.verifyAccessToken(token);

        // Provide user info to downstream handlers
        return handler(
          context.provide<Map<dynamic, dynamic>>(() => payload),
        );
      } on JWTExpiredException {
        return ApiResponse.unauthorized(message: 'Token expired');
      } on JWTException catch (e) {
        return ApiResponse.unauthorized(message: 'Invalid token: ${e.message}');
      } catch (e) {
        AppLogger.error('Auth middleware error: $e');
        return ApiResponse.internalError(message: 'Authentication failed');
      }
    };
  };
}
