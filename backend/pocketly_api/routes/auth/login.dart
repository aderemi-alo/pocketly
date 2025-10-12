import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _login(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

Future<Response> _login(RequestContext context) async {
  final authRepo = context.read<AuthRepository>();

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final deviceId = body['deviceId'] as String?;

    // Validate required fields
    if (email == null || password == null || deviceId == null) {
      return ApiResponse.badRequest(
        message: 'Email, password and device ID are required',
      );
    }

    // Find user
    final user = await authRepo.findUserByEmail(email);

    // Check if user exists and password matches
    if (user == null || !authRepo.verifyPassword(password, user.passwordHash)) {
      return ApiResponse.unauthorized(
        message: 'Invalid email or password',
      );
    }

    // Generate tokens
    final accessToken = authRepo.generateAccessToken(user);
    final refreshToken = authRepo.generateRefreshToken();

    // Store refresh token
    await authRepo.storeRefreshToken(
      userId: user.id,
      refreshToken: refreshToken,
      deviceId: deviceId,
    );

    final response = AuthResponse(
      user: UserResponse.fromEntity(user),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return ApiResponse.success(data: response.toJson());
  } catch (e) {
    AppLogger.error('Login error: $e');
    return ApiResponse.internalError(
      message: 'Internal server error',
      errors: {'error': e.toString()},
    );
  }
}
