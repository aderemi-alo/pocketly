import 'package:pocketly/core/core.dart';

class PasswordResetRepository {
  final ApiClient _apiClient;

  PasswordResetRepository(this._apiClient);

  /// Request password reset OTP
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/request-password-reset',
        data: {'email': email},
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to request password reset: ${e.toString()}');
    }
  }

  /// Reset password with OTP
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );

      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }
}
