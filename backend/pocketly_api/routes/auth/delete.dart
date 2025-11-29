import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.delete => _deleteAccount(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

Future<Response> _deleteAccount(RequestContext context) async {
  final authRepo = context.read<AuthRepository>();
  final userRepo = context.read<UserRepository>();

  try {
    // Extract JWT from Authorization header
    final authHeader = context.request.headers['authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return ApiResponse.unauthorized(
        message: 'Authorization token required',
      );
    }

    final token = authHeader.substring(7);

    // Verify JWT and extract user ID
    final payload = authRepo.verifyAccessToken(token);
    final userId = payload['uid'] as String;

    // Optional: Verify password before deletion for extra security
    final body = await context.request.json() as Map<String, dynamic>;
    final password = body['password'] as String?;

    if (password != null) {
      // Fetch user to verify password
      final user = await userRepo.findById(userId);

      if (user == null) {
        return ApiResponse.notFound(
          message: 'User not found',
        );
      }

      // Verify password
      if (!authRepo.verifyPassword(password, user.passwordHash)) {
        return ApiResponse.forbidden(
          message: 'Invalid password',
        );
      }
    }

    // Delete user (cascade will handle related data)
    final deleted = await userRepo.deleteUser(userId);

    if (!deleted) {
      return ApiResponse.notFound(
        message: 'User not found',
      );
    }

    return ApiResponse.success(
      data: {'message': 'Account deleted successfully'},
    );
  } on JWTExpiredException {
    return ApiResponse.unauthorized(message: 'Token expired');
  } on JWTException catch (e) {
    return ApiResponse.unauthorized(message: 'Invalid token: ${e.message}');
  } catch (e) {
    AppLogger.error('Delete account error: $e');
    return ApiResponse.internalError(
      message: 'Internal server error',
    );
  }
}
