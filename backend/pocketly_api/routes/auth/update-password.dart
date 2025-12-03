import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _updatePassword(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

Future<Response> _updatePassword(RequestContext context) async {
  // 1. Ensure user is authenticated using requireAuth middleware logic
  // Since we can't easily wrap this single handler in the middleware here without
  // a parent _middleware.dart, we'll manually check for the user payload
  // OR we can rely on a _middleware.dart in this directory if we add one.
  // However, looking at other files, it seems they might rely on a higher level middleware.
  // Let's check if there is a _middleware.dart in routes/auth/ that applies to all.
  // Yes, there is routes/auth/_middleware.dart but it only provides repositories.
  // So we need to explicitly use the requireAuth middleware or check for the payload.

  // Let's use the pipeline approach to apply middleware locally if needed,
  // but for now let's try to read the payload directly as if requireAuth was applied.
  // If it fails, we'll know we need to apply it.

  // Actually, the best practice in Dart Frog for a single route needing auth
  // when the group doesn't enforce it is to use a pipeline in the onRequest.

  final handler =
      Pipeline().addMiddleware(requireAuth()).addHandler((context) async {
    final authRepo = context.read<AuthRepository>();

    try {
      // Get user ID from context (provided by requireAuth)
      final payload = context.read<Map<dynamic, dynamic>>();
      final userId = payload['uid'] as String?;

      if (userId == null) {
        return ApiResponse.unauthorized(message: 'Invalid token payload');
      }

      final body = await context.request.json() as Map<String, dynamic>;
      final currentPassword = body['currentPassword'] as String?;
      final newPassword = body['newPassword'] as String?;

      if (currentPassword == null || newPassword == null) {
        return ApiResponse.badRequest(
          message: 'Current password and new password are required',
        );
      }

      if (newPassword.length < 6) {
        return ApiResponse.badRequest(
          message: 'Password must be at least 6 characters',
        );
      }

      // Find user to verify current password
      final user = await authRepo.findUserById(userId);
      if (user == null) {
        return ApiResponse.notFound(message: 'User not found');
      }

      // Verify current password
      if (!authRepo.verifyPassword(currentPassword, user.passwordHash)) {
        return ApiResponse.forbidden(message: 'Incorrect current password');
      }

      // Update password
      await authRepo.updatePassword(
        userId: userId,
        newPassword: newPassword,
      );

      AppLogger.info('Password updated for user: $userId');

      return ApiResponse.success(
        message: 'Password updated successfully',
        data: {},
      );
    } catch (e) {
      AppLogger.error('Update password error: $e');
      return ApiResponse.internalError(
        message: 'Failed to update password',
        errors: {'error': e.toString()},
      );
    }
  });

  return handler(context);
}
