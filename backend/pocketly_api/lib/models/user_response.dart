import 'package:pocketly_api/database/database.dart';

/// User data for API responses
/// Excludes sensitive fields like passwordHash
class UserResponse {
  /// Creates an instance of [UserResponse]
  const UserResponse({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [UserResponse] from a [User] entity
  factory UserResponse.fromEntity(User user) {
    return UserResponse(
      id: user.id,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// The user's unique identifier
  final String id;

  /// The user's name
  final String name;

  /// The user's email
  final String email;

  /// The date and time the user was created
  final DateTime? createdAt;

  /// The date and time the user was last updated
  final DateTime? updatedAt;

  /// Converts the user response to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Converts the user response to a minimal JSON object
  /// Only includes id, name, and email
  Map<String, dynamic> toMinimalJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
