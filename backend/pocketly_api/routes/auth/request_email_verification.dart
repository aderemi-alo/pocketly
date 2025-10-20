import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/services/email_service.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _requestEmailVerification(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

Future<Response> _requestEmailVerification(RequestContext context) async {
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

    // Check rate limiting - max 3 OTPs in 15 minutes
    final otpCount = await otpRepo.getOtpCountForEmail(
      email: user.email,
      purpose: OtpPurpose.emailVerification,
      timeWindow: const Duration(minutes: 15),
    );

    if (otpCount >= 3) {
      return ApiResponse.tooManyRequests(
        message: 'Too many verification requests. Please try again later.',
      );
    }

    // Generate and store OTP
    final otpCode = await otpRepo.createOtp(
      email: user.email,
      purpose: OtpPurpose.emailVerification,
    );

    // Send OTP email
    final emailSent = await emailService.sendEmailVerificationOtp(
      toEmail: user.email,
      toName: user.name,
      otpCode: otpCode,
    );

    if (!emailSent) {
      return ApiResponse.internalError(
        message: 'Failed to send verification email',
      );
    }

    final response = OtpResponse(
      message: 'Verification code sent to your email',
      email: user.email,
      expiresInMinutes: Settings.otpExpirationInMinutes,
    );

    return ApiResponse.success(
      message: 'Verification code sent successfully',
      data: response.toJson(),
    );
  } catch (e) {
    AppLogger.error('Request email verification error: $e');
    return ApiResponse.internalError(
      message: 'Internal server error',
      errors: {'error': e.toString()},
    );
  }
}
