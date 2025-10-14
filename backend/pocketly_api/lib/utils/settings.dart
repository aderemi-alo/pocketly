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

  static const int tokenExpirationInHours = 168; // 7 days
  static const int refreshTokenExpirationInDays = 30; // 30 days
}
