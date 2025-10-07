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
    required String expenseId,
    required String name,
    required double amount,
    required DateTime date,
    String? description,
    required String categoryId,
    required String categoryName,
    required IconData categoryIcon,
    required Color categoryColor,
  }) {
    this.expenseId;
    this.name;
    this.amount;
    this.date;
    this.description;
    this.categoryId;
    this.categoryName;
    categoryIconCodePoint = categoryIcon.codePoint;
    categoryColorValue = categoryColor.toARGB32();
  }
}
