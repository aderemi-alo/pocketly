import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getUserProfile(context),
    HttpMethod.put => _updateUserProfile(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

/// GET /auth/user - Get current user profile
Future<Response> _getUserProfile(RequestContext context) async {
  final userRepo = context.read<UserRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    // Fetch user details
    final user = await userRepo.findById(userId);

    if (user == null) {
      return ApiResponse.notFound(message: 'User not found');
    }

    final response = UserResponse.fromEntity(user).toJson();

    return ApiResponse.success(data: response);
  } catch (e) {
    AppLogger.error('Get user profile error: $e');
    return ApiResponse.internalError(message: 'Failed to fetch user profile');
  }
}

/// PUT /auth/user - Update user profile
Future<Response> _updateUserProfile(RequestContext context) async {
  final userRepo = context.read<UserRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    final body = await context.request.json() as Map<String, dynamic>;
    final name = body['name'] as String?;

    // Validate required fields
    if (name == null || name.trim().isEmpty) {
      return ApiResponse.badRequest(
        message: 'Name is required',
      );
    }

    // Check if name is different from current
    final currentUser = await userRepo.findById(userId);
    if (currentUser == null) {
      return ApiResponse.notFound(message: 'User not found');
    }

    if (currentUser.name == name.trim()) {
      return ApiResponse.badRequest(
        message: 'Name is the same as current name',
      );
    }

    // Update the user
    final success = await userRepo.updateUser(
      userId: userId,
      name: name.trim(),
    );

    if (!success) {
      return ApiResponse.internalError(
          message: 'Failed to update user profile');
    }

    // Fetch and return the updated user
    final updatedUser = await userRepo.findById(userId);

    if (updatedUser == null) {
      return ApiResponse.internalError(
        message: 'Failed to fetch updated user profile',
      );
    }

    final response = UserResponse.fromEntity(updatedUser).toJson();

    return ApiResponse.success(data: response);
  } catch (e) {
    AppLogger.error('Update user profile error: $e');
    return ApiResponse.internalError(message: 'Failed to update user profile');
  }
}
