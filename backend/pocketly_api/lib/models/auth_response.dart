import 'package:pocketly_api/models/user_response.dart';

/// Authentication response with user data and tokens
class AuthResponse {
  /// Creates an instance of [AuthResponse]
  const AuthResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
    this.message,
  });

  /// The authenticated user's data
  final UserResponse user;

  /// The JWT access token
  final String accessToken;

  /// The refresh token (optional for token refresh responses)
  final String? refreshToken;

  /// Optional message
  final String? message;

  /// Converts the auth response to JSON
  Map<String, dynamic> toJson({bool includeTimestamps = false}) {
    return {
      if (message != null) 'message': message,
      'user': includeTimestamps ? user.toJson() : user.toMinimalJson(),
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}
