import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/models/models.dart';

/// Expense data for API responses
class ExpenseResponse {
  /// Creates an instance of [ExpenseResponse]
  const ExpenseResponse({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    this.categoryId,
    this.category,
    this.userId,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  /// Creates a [ExpenseResponse] from a [Expense] entity
  /// Only includes category ID
  factory ExpenseResponse.fromEntity(Expense expense) {
    return ExpenseResponse(
      id: expense.id,
      name: expense.name,
      amount: expense.amount,
      date: expense.date,
      categoryId: expense.categoryId,
      userId: expense.userId,
      description: expense.description,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
      isDeleted: expense.isDeleted,
    );
  }

  /// Creates a [ExpenseResponse] from a [Expense] entity
  /// with full category details
  factory ExpenseResponse.fromEntityWithCategory(
    Expense expense,
    Category? categoryEntity,
  ) {
    return ExpenseResponse(
      id: expense.id,
      name: expense.name,
      amount: expense.amount,
      date: expense.date,
      categoryId: expense.categoryId,
      category: categoryEntity != null
          ? CategoryResponse.fromEntity(categoryEntity)
          : null,
      userId: expense.userId,
      description: expense.description,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
      isDeleted: expense.isDeleted,
    );
  }

  /// The expense's unique identifier
  final String id;

  /// The expense's name
  final String name;

  /// The expense's amount
  final double amount;

  /// The expense's date
  final DateTime date;

  /// The expense's category ID
  final String? categoryId;

  /// The expense's category details (optional, for detailed responses)
  final CategoryResponse? category;

  /// The user ID (for multi-user support)
  final String? userId;

  /// The expense's description
  final String? description;

  /// The date and time the expense was created
  final DateTime? createdAt;

  /// The date and time the expense was last updated
  final DateTime? updatedAt;

  /// Whether the expense is deleted (soft delete)
  final bool? isDeleted;

  /// Converts the expense response to JSON with full details
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      if (categoryId != null) 'categoryId': categoryId,
      if (category != null) 'category': category!.toJson(),
      if (userId != null) 'userId': userId,
      if (description != null) 'description': description,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (isDeleted != null) 'isDeleted': isDeleted,
    };
  }

  /// Converts the expense response to a minimal JSON object
  /// Only includes essential fields for list views
  Map<String, dynamic> toMinimalJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      if (categoryId != null) 'categoryId': categoryId,
      if (category != null)
        'category': {
          'id': category!.id,
          'name': category!.name,
          'icon': category!.icon,
          'color': category!.color,
        },
    };
  }
}
