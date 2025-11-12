import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'expense_hive.g.dart';

@HiveType(typeId: 0)
class ExpenseHive extends HiveObject {
  @HiveField(0)
  late String expenseId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  String? description;

  // Category fields
  @HiveField(5)
  late String categoryId;

  @HiveField(6)
  late String categoryName;

  @HiveField(7)
  late int categoryIconCodePoint;

  @HiveField(8)
  late int categoryColorValue;

  @HiveField(9)
  late DateTime updatedAt;

  @HiveField(10)
  late bool isDeleted;

  ExpenseHive();

  ExpenseHive.create({
    required this.expenseId,
    required this.name,
    required this.amount,
    required this.date,
    this.description,
    required this.categoryId,
    required this.categoryName,
    required IconData categoryIcon,
    required Color categoryColor,
    DateTime? updatedAt,
    bool isDeleted = false,
  }) {
    categoryIconCodePoint = categoryIcon.codePoint;
    categoryColorValue = categoryColor.toARGB32();
    this.updatedAt = updatedAt ?? DateTime.now();
  }
}
