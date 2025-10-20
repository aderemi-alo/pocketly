import 'package:pocketly/core/core.dart';

class EmailVerificationRepository {
  final ApiClient _apiClient;

  EmailVerificationRepository(this._apiClient);

  /// Request email verification OTP
  Future<Map<String, dynamic>> requestEmailVerification(String email) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/request-email-verification',
        data: {'email': email},
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to request email verification: ${e.toString()}');
    }
  }

  /// Verify email with OTP
  Future<Map<String, dynamic>> verifyEmail(String email, String otp) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/verify-email',
        data: {'email': email, 'otp': otp},
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to verify email: ${e.toString()}');
    }
  }
}
