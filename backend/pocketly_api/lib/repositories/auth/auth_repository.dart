import 'package:drift/drift.dart';
import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/utils/encryption.dart';
import 'package:pocketly_api/utils/settings.dart';

/// Repository for authentication-related operations
class AuthRepository {
  /// Creates an instance of [AuthRepository]
  const AuthRepository(this._db);

  final PocketlyDatabase _db;

  /// Finds a user by email
  Future<User?> findUserByEmail(String email) async {
    return (_db.select(_db.users)..where((user) => user.email.equals(email)))
        .getSingleOrNull();
  }

  /// Finds a user by ID
  Future<User?> findUserById(String userId) async {
    return (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
  }

  /// Stores a refresh token in the database
  Future<void> storeRefreshToken({
    required String userId,
    required String refreshToken,
    required String deviceId,
  }) async {
    final refreshTokenHash = Encryption.hashRefreshToken(refreshToken);

    // Delete existing tokens for this user/device combination first
    await (_db.delete(_db.refreshTokens)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.deviceId.equals(deviceId)))
        .go();

    // Then insert the new token with proper expiration date
    await _db.into(_db.refreshTokens).insert(
          RefreshTokensCompanion.insert(
            userId: userId,
            tokenHash: refreshTokenHash,
            deviceId: deviceId,
            expiresAt: Value(
              DateTime.now().add(
                Duration(days: Settings.refreshTokenExpirationInDays),
              ),
            ),
          ),
        );
  }

  /// Finds a refresh token by hash and device ID
  Future<RefreshToken?> findRefreshToken({
    required String refreshToken,
    required String deviceId,
  }) async {
    final refreshTokenHash = Encryption.hashRefreshToken(refreshToken);

    return (_db.select(_db.refreshTokens)
          ..where((t) => t.tokenHash.equals(refreshTokenHash))
          ..where((t) => t.deviceId.equals(deviceId)))
        .getSingleOrNull();
  }

  /// Deletes a refresh token by ID
  Future<void> deleteRefreshTokenById(String tokenId) async {
    await (_db.delete(_db.refreshTokens)..where((t) => t.id.equals(tokenId)))
        .go();
  }

  /// Rotates a refresh token (deletes old, inserts new)
  Future<void> rotateRefreshToken({
    required String oldTokenId,
    required String userId,
    required String newRefreshToken,
    required String deviceId,
  }) async {
    final newRefreshTokenHash = Encryption.hashRefreshToken(newRefreshToken);

    await _db.transaction(() async {
      await (_db.delete(_db.refreshTokens)
            ..where((t) => t.id.equals(oldTokenId)))
          .go();

      await _db.into(_db.refreshTokens).insert(
            RefreshTokensCompanion.insert(
              userId: userId,
              tokenHash: newRefreshTokenHash,
              deviceId: deviceId,
              expiresAt: Value(
                DateTime.now().add(
                  Duration(days: Settings.refreshTokenExpirationInDays),
                ),
              ),
            ),
          );
    });
  }

  /// Deletes refresh tokens for a user
  /// If [deviceId] is provided, only delete for that device
  /// Otherwise, delete all tokens for the user
  Future<void> deleteUserRefreshTokens({
    required String userId,
    String? deviceId,
  }) async {
    if (deviceId != null) {
      await (_db.delete(_db.refreshTokens)
            ..where((t) => t.userId.equals(userId))
            ..where((t) => t.deviceId.equals(deviceId)))
          .go();
    } else {
      await (_db.delete(_db.refreshTokens)
            ..where((t) => t.userId.equals(userId)))
          .go();
    }
  }

  /// Checks if a password matches the hash
  bool verifyPassword(String password, String passwordHash) {
    return Encryption.checkPassword(password, passwordHash);
  }

  /// Generates an access token for a user
  String generateAccessToken(User user) {
    return Encryption.generateAccessToken(user: user);
  }

  /// Generates a refresh token
  String generateRefreshToken() {
    return Encryption.generateRefreshToken();
  }

  /// Verifies an access token and returns the payload
  Map<String, dynamic> verifyAccessToken(String token) {
    final payload = Encryption.verifyAccessToken(token);
    return Map<String, dynamic>.from(payload);
  }
}
