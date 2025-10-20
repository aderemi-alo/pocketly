import 'dart:math';

/// Utility class for generating secure OTP codes
class OtpGenerator {
  static final _random = Random.secure();

  /// Generates a secure 6-digit OTP code
  static String generateOtp() {
    final code = _random.nextInt(900000) + 100000;
    return code.toString();
  }

  /// Validates if a string is a valid OTP format
  static bool isValidOtpFormat(String otp) {
    return otp.length == 6 && int.tryParse(otp) != null;
  }
}
