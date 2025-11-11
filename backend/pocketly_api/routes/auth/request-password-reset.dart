import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/services/email_service.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _requestPasswordReset(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

Future<Response> _requestPasswordReset(RequestContext context) async {
  final otpRepo = context.read<OtpRepository>();
  final userRepo = context.read<UserRepository>();
  final emailService = context.read<EmailService>();

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;

    // Validate email
    if (email == null || email.isEmpty) {
      return ApiResponse.badRequest(
        message: 'Email is required',
      );
    }

    // Check if user exists
    final user = await userRepo.findByEmail(email);

    // Don't reveal if user exists or not for security
    // Always return success message

    if (user != null) {
      // Check rate limiting - max 3 OTPs in 15 minutes
      final otpCount = await otpRepo.getOtpCountForEmail(
        email: email,
        purpose: OtpPurpose.passwordReset,
        timeWindow: const Duration(minutes: 15),
      );

      if (otpCount < 3) {
        // Generate and store OTP
        final otpCode = await otpRepo.createOtp(
          email: email,
          purpose: OtpPurpose.passwordReset,
        );

        // Send OTP email
        await emailService.sendPasswordResetOtp(
          toEmail: user.email,
          toName: user.name,
          otpCode: otpCode,
        );
      }
    }

    const response = OtpResponse(
      message:
          'If an account exists with this email, a password reset code has been sent',
      expiresInMinutes: Settings.otpExpirationInMinutes,
    );

    return ApiResponse.success(
      message: 'Password reset code sent successfully',
      data: response.toJson(),
    );
  } catch (e) {
    AppLogger.error('Request password reset error: $e');
    return ApiResponse.internalError(
      message: 'Internal server error',
      errors: {'error': e.toString()},
    );
  }
}
