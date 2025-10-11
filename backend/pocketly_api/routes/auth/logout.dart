import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _logout(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

Future<Response> _logout(RequestContext context) async {
  final authRepo = context.read<AuthRepository>();

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

    final body = await context.request.json() as Map<String, dynamic>;
    final deviceId = body['deviceId'] as String?;

    // If deviceId is provided, logout from that specific device
    // If not provided, logout from all devices
    await authRepo.deleteUserRefreshTokens(
      userId: userId,
      deviceId: deviceId,
    );

    return ApiResponse.success(
      data: {
        'message': deviceId != null
            ? 'Logged out from device successfully'
            : 'Logged out from all devices successfully',
      },
    );
  } on JWTExpiredException {
    return ApiResponse.unauthorized(message: 'Token expired');
  } on JWTException catch (e) {
    return ApiResponse.unauthorized(message: 'Invalid token: ${e.message}');
  } catch (e) {
    AppLogger.error('Logout error: $e');
    return ApiResponse.internalError(
      message: 'Internal server error',
    );
  }
}
