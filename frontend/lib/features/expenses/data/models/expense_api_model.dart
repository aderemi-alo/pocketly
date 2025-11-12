import 'package:pocketly/features/expenses/data/models/category_api_model.dart';

class ExpenseApiModel {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String categoryId;
  final CategoryApiModel? category;
  final String? description;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool? isDeleted;

  const ExpenseApiModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.category,
    this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted,
  });

  factory ExpenseApiModel.fromJson(Map<String, dynamic> json) {
    return ExpenseApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      categoryId: json['categoryId'] as String,
      category: json['category'] != null
          ? CategoryApiModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      description: json['description'] as String?,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      if (category != null) 'category': category!.toJson(),
      if (description != null) 'description': description,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (isDeleted != null) 'isDeleted': isDeleted,
    };
  }

  /// Create request JSON for creating expense
  Map<String, dynamic> toCreateRequest() {
    return {
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }

  /// Create request JSON for updating expense
  Map<String, dynamic> toUpdateRequest() {
    return {
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      if (description != null) 'description': description,
    };
  }

  ExpenseApiModel copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? date,
    String? categoryId,
    CategoryApiModel? category,
    String? description,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ExpenseApiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() => 'ExpenseApiModel(id: $id, name: $name, amount: $amount)';
}
