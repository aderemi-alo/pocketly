import 'package:isar/isar.dart';
import 'package:flutter/material.dart';

part 'expense_isar.g.dart';

@collection
class ExpenseIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String expenseId;

  late String name;
  late double amount;
  late DateTime date;
  String? description;

  // Category fields
  late String categoryId;
  late String categoryName;
  late int categoryIconCodePoint;
  late int categoryColorValue;

  ExpenseIsar();

  ExpenseIsar.create({
    required this.expenseId,
    required this.name,
    required this.amount,
    required this.date,
    this.description,
    required this.categoryId,
    required this.categoryName,
    required IconData categoryIcon,
    required Color categoryColor,
  }) {
    categoryIconCodePoint = categoryIcon.codePoint;
    categoryColorValue = categoryColor.toARGB32();
  }
}
