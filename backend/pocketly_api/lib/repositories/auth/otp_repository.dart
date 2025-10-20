import 'package:drift/drift.dart';
import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/utils/utils.dart';

/// Purpose of the OTP
enum OtpPurpose {
  /// OTP for email verification
  emailVerification('email_verification'),

  /// OTP for password reset
  passwordReset('password_reset');

  const OtpPurpose(this.value);

  /// The string value of the purpose
  final String value;
}

/// Repository for OTP-related operations
class OtpRepository {
  /// Creates an instance of [OtpRepository]
  const OtpRepository(this._db);

  final PocketlyDatabase _db;

  /// Creates a new OTP
  Future<String> createOtp({
    required String email,
    required OtpPurpose purpose,
  }) async {
    // First, cleanup old OTPs for this email and purpose
    await cleanupUserOtps(email: email, purpose: purpose);

    // Generate new OTP code
    final otpCode = OtpGenerator.generateOtp();
    final otpCodeHash = Encryption.encryptPassword(otpCode);

    final expiresAt =
        DateTime.now().add(Duration(minutes: Settings.otpExpirationInMinutes));

    final companion = OtpsCompanion.insert(
      email: email,
      otpCodeHash: otpCodeHash,
      purpose: purpose.value,
      expiresAt: expiresAt,
    );

    await _db.into(_db.otps).insert(companion);

    return otpCode;
  }

  /// Verifies an OTP code
  Future<OtpVerificationResult> verifyOtp({
    required String email,
    required String otpCode,
    required OtpPurpose purpose,
  }) async {
    // First cleanup expired OTPs
    await cleanupExpiredOtps();

    // Find the OTP for this email and purpose
    final otp = await (_db.select(_db.otps)
          ..where((o) => o.email.equals(email))
          ..where((o) => o.purpose.equals(purpose.value))
          ..where((o) => o.isUsed.equals(false))
          ..orderBy([(o) => OrderingTerm.desc(o.createdAt)])
          ..limit(1))
        .getSingleOrNull();

    if (otp == null) {
      return OtpVerificationResult.notFound;
    }

    // Check if OTP has expired
    if (otp.expiresAt.isBefore(DateTime.now())) {
      return OtpVerificationResult.expired;
    }

    // Check if max attempts exceeded
    if (otp.attemptCount >= Settings.maxOtpAttempts) {
      return OtpVerificationResult.maxAttemptsExceeded;
    }

    // Verify the OTP code
    final isValid = Encryption.checkPassword(otpCode, otp.otpCodeHash);

    if (isValid) {
      // Mark OTP as used
      await (_db.update(_db.otps)..where((o) => o.id.equals(otp.id))).write(
        OtpsCompanion(
          isUsed: const Value(true),
        ),
      );

      return OtpVerificationResult.success;
    } else {
      // Increment attempt count
      await (_db.update(_db.otps)..where((o) => o.id.equals(otp.id))).write(
        OtpsCompanion(
          attemptCount: Value(otp.attemptCount + 1),
        ),
      );

      return OtpVerificationResult.invalid;
    }
  }

  /// Checks if a valid OTP exists for the given email and purpose
  Future<bool> hasValidOtp({
    required String email,
    required OtpPurpose purpose,
  }) async {
    final otp = await (_db.select(_db.otps)
          ..where((o) => o.email.equals(email))
          ..where((o) => o.purpose.equals(purpose.value))
          ..where((o) => o.isUsed.equals(false))
          ..where((o) => o.expiresAt.isBiggerThanValue(DateTime.now()))
          ..limit(1))
        .getSingleOrNull();

    return otp != null;
  }

  /// Cleans up old/expired OTPs for a specific user and purpose
  Future<void> cleanupUserOtps({
    required String email,
    OtpPurpose? purpose,
  }) async {
    final query = _db.delete(_db.otps)..where((o) => o.email.equals(email));

    if (purpose != null) {
      query.where((o) => o.purpose.equals(purpose.value));
    }

    await query.go();
  }

  /// Cleans up all expired OTPs from the database
  Future<void> cleanupExpiredOtps() async {
    await (_db.delete(_db.otps)
          ..where((o) => o.expiresAt.isSmallerThanValue(DateTime.now())))
        .go();
  }

  /// Cleans up all used OTPs from the database
  Future<void> cleanupUsedOtps() async {
    await (_db.delete(_db.otps)..where((o) => o.isUsed.equals(true))).go();
  }

  /// Gets the count of OTPs for a specific email and purpose within a time window
  /// Useful for rate limiting
  Future<int> getOtpCountForEmail({
    required String email,
    required OtpPurpose purpose,
    required Duration timeWindow,
  }) async {
    final cutoffTime = DateTime.now().subtract(timeWindow);

    final count = await (_db.selectOnly(_db.otps)
          ..addColumns([_db.otps.id.count()])
          ..where(_db.otps.email.equals(email))
          ..where(_db.otps.purpose.equals(purpose.value))
          ..where(_db.otps.createdAt.isBiggerThanValue(cutoffTime)))
        .map((row) => row.read(_db.otps.id.count()) ?? 0)
        .getSingle();

    return count;
  }
}

/// Result of OTP verification
enum OtpVerificationResult {
  /// OTP verification successful
  success,

  /// OTP not found
  notFound,

  /// OTP has expired
  expired,

  /// OTP code is invalid
  invalid,

  /// Maximum verification attempts exceeded
  maxAttemptsExceeded,
}
