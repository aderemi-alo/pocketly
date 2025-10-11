import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _register(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

Future<Response> _register(RequestContext context) async {
  final authRepo = context.read<AuthRepository>();
  final userRepo = context.read<UserRepository>();

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final name = body['name'] as String?;
    final deviceId = body['deviceId'] as String?;

    // Validate required fields
    if (email == null || password == null || name == null || deviceId == null) {
      return ApiResponse.badRequest(
        message: 'Email, password, name and device ID are required',
      );
    }

    // Validate password length
    if (password.length < 8) {
      return ApiResponse.badRequest(
        message: 'Password must be at least 8 characters long',
      );
    }

    // Check if user already exists
    final emailExists = await userRepo.emailExists(email);

    if (emailExists) {
      return ApiResponse.conflict(
        message: 'User with this email already exists',
      );
    }

    // Hash password
    final passwordHash = Encryption.encryptPassword(password);

    // Create user
    final newUser = await userRepo.createUser(
      name: name,
      email: email,
      passwordHash: passwordHash,
    );

    // Generate tokens
    final accessToken = authRepo.generateAccessToken(newUser);
    final refreshToken = authRepo.generateRefreshToken();

    // Store refresh token
    await authRepo.storeRefreshToken(
      userId: newUser.id,
      refreshToken: refreshToken,
      deviceId: deviceId,
    );

    final response = AuthResponse(
      user: UserResponse.fromEntity(newUser),
      accessToken: accessToken,
      refreshToken: refreshToken,
      message: 'User created successfully',
    );

    return ApiResponse.created(
      message: 'User created successfully',
      data: response.toJson(includeTimestamps: true),
    );
  } catch (e) {
    AppLogger.error('Registration error: $e');
    return ApiResponse.internalError(
      message: 'Internal server error',
      errors: {'error': e.toString()},
    );
  }
}
