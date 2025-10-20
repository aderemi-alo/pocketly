import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _resetPassword(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

Future<Response> _resetPassword(RequestContext context) async {
  final otpRepo = context.read<OtpRepository>();
  final userRepo = context.read<UserRepository>();

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final otpCode = body['otp'] as String?;
    final newPassword = body['newPassword'] as String?;

    // Validate required fields
    if (email == null || email.isEmpty) {
      return ApiResponse.badRequest(message: 'Email is required');
    }

    if (otpCode == null || !OtpGenerator.isValidOtpFormat(otpCode)) {
      return ApiResponse.badRequest(
        message: 'Valid 6-digit OTP code is required',
      );
    }

    if (newPassword == null || newPassword.isEmpty) {
      return ApiResponse.badRequest(message: 'New password is required');
    }

    // Validate password length
    if (newPassword.length < 8) {
      return ApiResponse.badRequest(
        message: 'Password must be at least 8 characters long',
      );
    }

    // Check if user exists
    final user = await userRepo.findByEmail(email);

    if (user == null) {
      return ApiResponse.badRequest(
        message: 'Invalid email or verification code',
      );
    }

    // Verify OTP
    final result = await otpRepo.verifyOtp(
      email: email,
      otpCode: otpCode,
      purpose: OtpPurpose.passwordReset,
    );

    switch (result) {
      case OtpVerificationResult.success:
        // Hash new password
        final newPasswordHash = Encryption.encryptPassword(newPassword);

        // Update user's password
        final updated = await userRepo.updateUser(
          userId: user.id,
          passwordHash: newPasswordHash,
        );

        if (!updated) {
          return ApiResponse.internalError(
            message: 'Failed to update password',
          );
        }

        // Cleanup used OTPs for this user
        await otpRepo.cleanupUserOtps(email: email);

        return ApiResponse.success(
          message: 'Password reset successfully',
          data: null,
        );

      case OtpVerificationResult.notFound:
        return ApiResponse.badRequest(
          message:
              'Invalid or expired verification code. Please request a new one.',
        );

      case OtpVerificationResult.expired:
        return ApiResponse.badRequest(
          message: 'Verification code has expired. Please request a new one.',
        );

      case OtpVerificationResult.invalid:
        return ApiResponse.badRequest(
          message: 'Invalid verification code. Please try again.',
        );

      case OtpVerificationResult.maxAttemptsExceeded:
        return ApiResponse.badRequest(
          message:
              'Maximum verification attempts exceeded. Please request a new code.',
        );
    }
  } catch (e) {
    AppLogger.error('Reset password error: $e');
    return ApiResponse.internalError(
      message: 'Internal server error',
      errors: {'error': e.toString()},
    );
  }
}
