import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _verifyEmail(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

Future<Response> _verifyEmail(RequestContext context) async {
  final otpRepo = context.read<OtpRepository>();
  final userRepo = context.read<UserRepository>();

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final otpCode = body['otp'] as String?;

    // Validate email
    if (email == null || email.isEmpty) {
      return ApiResponse.badRequest(message: 'Email is required');
    }

    // Check if user exists
    final user = await userRepo.findByEmail(email);

    if (user == null) {
      return ApiResponse.notFound(
        message: 'No account found with this email',
      );
    }

    // Check if email is already verified
    if (user.isEmailVerified) {
      return ApiResponse.badRequest(
        message: 'Email is already verified',
      );
    }

    // Validate OTP code
    if (otpCode == null || !OtpGenerator.isValidOtpFormat(otpCode)) {
      return ApiResponse.badRequest(
        message: 'Valid 6-digit OTP code is required',
      );
    }

    // Verify OTP
    final result = await otpRepo.verifyOtp(
      email: user.email,
      otpCode: otpCode,
      purpose: OtpPurpose.emailVerification,
    );

    switch (result) {
      case OtpVerificationResult.success:
        // Mark email as verified by updating the user record
        await userRepo.updateEmailVerificationStatus(
          userId: user.id,
          isVerified: true,
        );

        // Cleanup used OTPs for this user
        await otpRepo.cleanupUserOtps(email: user.email);

        return ApiResponse.success(
          message: 'Email verified successfully',
          data: null,
        );

      case OtpVerificationResult.notFound:
        return ApiResponse.notFound(
          message:
              'No valid verification code found. Please request a new one.',
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
    AppLogger.error('Verify email error: $e');
    return ApiResponse.internalError(
      message: 'Internal server error',
      errors: {'error': e.toString()},
    );
  }
}
