// ignore_for_file: public_member_api_docs

import 'dart:io';

class Settings {
  // Database Connection Settings
  // These values will be read from environment variables at compile time.
  // The second argument is the default/fallback value if the environment variable is not set.
  // Database Connection Settings
  // Using Platform.environment for runtime access to environment variables

  static String dbName = Platform.environment['DB_NAME'] ?? 'gray-horst.db';

  static String jwtSecretKey =
      Platform.environment['JWT_SECRET_KEY'] ?? 'secret-key';

  static const int tokenExpirationInMinutes = 30; // 30 minutes
  static const int refreshTokenExpirationInDays = 14; // 14 days

  // Brevo Email Service Settings
  static String brevoApiKey = Platform.environment['BREVO_API_KEY'] ?? '';

  static String brevoSenderEmail =
      Platform.environment['BREVO_SENDER_EMAIL'] ?? 'noreply@pocketly.app';

  static String brevoSenderName =
      Platform.environment['BREVO_SENDER_NAME'] ?? 'Pocketly';

  // OTP Settings
  static const int otpExpirationInMinutes = 10; // 10 minutes
  static const int maxOtpAttempts = 3; // Max verification attempts
}
