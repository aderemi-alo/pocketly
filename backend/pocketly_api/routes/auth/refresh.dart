import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _refreshToken(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

Future<Response> _refreshToken(RequestContext context) async {
  final authRepo = context.read<AuthRepository>();

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final refreshToken = body['refreshToken'] as String?;
    final deviceId = body['deviceId'] as String?;

    if (refreshToken == null || deviceId == null) {
      return ApiResponse.badRequest(
        message: 'Refresh token and device ID are required',
      );
    }

    // Find the refresh token in database
    final storedToken = await authRepo.findRefreshToken(
      refreshToken: refreshToken,
      deviceId: deviceId,
    );

    if (storedToken == null) {
      return ApiResponse.unauthorized(
        message: 'Invalid or expired refresh token',
      );
    }

    // Check if token is expired
    if (storedToken.expiresAt.isBefore(DateTime.now())) {
      // Delete expired token
      await authRepo.deleteRefreshTokenById(storedToken.id);

      return ApiResponse.unauthorized(
        message: 'Refresh token expired',
      );
    }

    // Get user details
    final user = await authRepo.findUserById(storedToken.userId);

    if (user == null) {
      return ApiResponse.notFound(
        message: 'User not found',
      );
    }

    // Generate new access token
    final newAccessToken = authRepo.generateAccessToken(user);

    // Optional: Implement refresh token rotation for better security
    final rotateRefreshToken = body['rotateToken'] as bool? ?? false;
    String? newRefreshToken;

    if (rotateRefreshToken) {
      // Generate new refresh token
      newRefreshToken = authRepo.generateRefreshToken();

      // Rotate tokens (delete old, insert new)
      await authRepo.rotateRefreshToken(
        oldTokenId: storedToken.id,
        userId: user.id,
        newRefreshToken: newRefreshToken,
        deviceId: deviceId,
      );
    }

    final response = AuthResponse(
      user: UserResponse.fromEntity(user),
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );

    return ApiResponse.success(data: response.toJson());
  } catch (e) {
    AppLogger.error('Refresh token error: $e');
    return ApiResponse.internalError(
      message: 'Internal server error',
    );
  }
}
