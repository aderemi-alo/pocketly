/// Response model for OTP operations
class OtpResponse {
  /// Creates an instance of [OtpResponse]
  const OtpResponse({
    required this.message,
    this.email,
    this.expiresInMinutes,
  });

  /// The response message
  final String message;

  /// The email the OTP was sent to (optional)
  final String? email;

  /// How many minutes until the OTP expires
  final int? expiresInMinutes;

  /// Converts the OTP response to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (email != null) 'email': email,
      if (expiresInMinutes != null) 'expiresInMinutes': expiresInMinutes,
    };
  }
}
