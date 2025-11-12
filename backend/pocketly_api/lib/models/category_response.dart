import 'package:pocketly_api/database/database.dart';

/// Category data for API responses
class CategoryResponse {
  /// Creates an instance of [CategoryResponse]
  const CategoryResponse({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isPredefined,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  /// Creates a [CategoryResponse] from a [Category] entity
  factory CategoryResponse.fromEntity(Category category) {
    return CategoryResponse(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      isPredefined: category.userId == null,
      userId: category.userId,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      isDeleted: category.isDeleted,
    );
  }

  /// The category's unique identifier
  final String id;

  /// The category's name
  final String name;

  /// The category's icon name
  final String icon;

  /// The category's color (hex code)
  final String color;

  /// Whether this is a predefined system category
  final bool isPredefined;

  /// The user ID (null for predefined categories)
  final String? userId;

  /// The date and time the category was created
  final DateTime? createdAt;

  /// The date and time the category was last updated
  final DateTime? updatedAt;

  /// Whether the category is deleted (soft delete)
  final bool? isDeleted;

  /// Converts the category response to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isPredefined': isPredefined,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (isDeleted != null) 'isDeleted': isDeleted,
    };
  }

  /// Converts the category response to a minimal JSON object
  /// Only includes essential fields
  Map<String, dynamic> toMinimalJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isPredefined': isPredefined,
    };
  }
}
