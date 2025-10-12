// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/utils/logger.dart';
import 'package:pocketly_api/utils/settings.dart';

class Encryption {
  static String generateAccessToken({
    required User user,
  }) {
    final jwt = JWT(
      {
        'name': user.name,
        'uid': user.id,
      },
    );

    return jwt.sign(
      SecretKey(Settings.jwtSecretKey),
      expiresIn: const Duration(hours: Settings.tokenExpirationInHours),
    );
  }

  static Map<dynamic, dynamic> verifyAccessToken(String token) {
    final jwt = JWT.verify(
      token,
      SecretKey(Settings.jwtSecretKey),
    );
    return jwt.payload as Map;
  }

  static String generateRefreshToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hashRefreshToken(String token) {
    return sha256.convert(utf8.encode(token)).toString();
  }

  static bool verifyRefreshToken(String token, String storedHash) {
    return hashRefreshToken(token) == storedHash;
  }

  static String encryptPassword(String pw, {int costFactor = 10}) {
    // Validate cost factor to be within bcrypt's acceptable range
    if (costFactor < 4 || costFactor > 31) {
      AppLogger.debug(
        // ignore: lines_longer_than_80_chars
        'Warning: Invalid bcrypt cost factor ($costFactor). Reverting to default of 10.',
      );
    }

    try {
      // BCrypt.gensalt() generates a random salt. The 'rounds' parameter
      // sets the work factor (cost).
      final salt = BCrypt.gensalt(logRounds: costFactor);

      // BCrypt.hashpw() combines the plain string with the salt and hashes it.
      final hashedPassword = BCrypt.hashpw(pw, salt);

      return hashedPassword;
    } catch (e) {
      AppLogger.warning('Error hashing string with bcrypt: $e');
      return '';
    }
  }

  static bool checkPassword(String pw, String hashedPwFromDb) {
    return BCrypt.checkpw(pw, hashedPwFromDb);
  }
}
