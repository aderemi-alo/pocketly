import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pocketly/features/expenses/data/database/hive_database.dart';
import 'package:pocketly/features/expenses/data/models/expense_hive.dart';
import 'package:pocketly/features/expenses/domain/models/expense.dart';
import 'package:pocketly/features/expenses/domain/models/category.dart';

class ExpenseHiveRepository {
  Box<ExpenseHive> get _box => HiveDatabase.expenseBox;

  /// Convert ExpenseHive to Expense domain model
  Expense _toDomainModel(ExpenseHive expenseHive) {
    try {
      return Expense(
        id: expenseHive.expenseId,
        name: expenseHive.name,
        amount: expenseHive.amount,
        date: expenseHive.date,
        description: expenseHive.description,
        category: Category(
          id: expenseHive.categoryId,
          name: expenseHive.categoryName,
          icon: IconData(
            expenseHive.categoryIconCodePoint,
            fontFamily: 'MaterialIcons',
          ),
          color: Color(expenseHive.categoryColorValue),
        ),
      );
    } catch (e) {
      debugPrint('Failed to convert ExpenseHive to Expense domain model: $e');
      rethrow;
    }
  }

  /// Convert Expense domain model to ExpenseHive
  ExpenseHive _toHiveModel(Expense expense) {
    try {
      return ExpenseHive.create(
        expenseId: expense.id,
        name: expense.name,
        amount: expense.amount,
        date: expense.date,
        description: expense.description,
        categoryId: expense.category.id,
        categoryName: expense.category.name,
        categoryIcon: expense.category.icon,
        categoryColor: expense.category.color,
      );
    } catch (e) {
      debugPrint('Failed to convert Expense domain model to ExpenseHive: $e');
      rethrow;
    }
  }

  /// Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    final expenses = _box.values.toList();
    return expenses.map(_toDomainModel).toList();
  }

  /// Get expense by ID
  Future<Expense?> getExpenseById(String expenseId) async {
    final expense = _box.values
        .where((e) => e.expenseId == expenseId)
        .firstOrNull;

    return expense != null ? _toDomainModel(expense) : null;
  }

  /// Add new expense
  Future<void> addExpense(Expense expense) async {
    try {
      final expenseHive = _toHiveModel(expense);
      await _box.add(expenseHive);
    } catch (e) {
      debugPrint('Failed to add expense: $e');
      rethrow;
    }
  }

  /// Update existing expense
  Future<void> updateExpense(Expense expense) async {
    final existingExpense = _box.values
        .where((e) => e.expenseId == expense.id)
        .firstOrNull;

    if (existingExpense != null) {
      final updatedExpense = _toHiveModel(expense);
      final index = _box.values.toList().indexOf(existingExpense);
      await _box.putAt(index, updatedExpense);
    }
  }

  /// Delete expense
  Future<void> deleteExpense(String expenseId) async {
    final expense = _box.values
        .where((e) => e.expenseId == expenseId)
        .firstOrNull;

    if (expense != null) {
      final index = _box.values.toList().indexOf(expense);
      await _box.deleteAt(index);
    }
  }

  /// Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final filteredExpenses = _box.values
        .where(
          (expense) =>
              expense.date.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              expense.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();

    return filteredExpenses.map(_toDomainModel).toList();
  }

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final filteredExpenses = _box.values
        .where((expense) => expense.categoryId == categoryId)
        .toList();

    return filteredExpenses.map(_toDomainModel).toList();
  }

  /// Get expenses by amount range
  Future<List<Expense>> getExpenseByAmount(
    double lowerAmount,
    double upperAmount,
  ) async {
    final filteredExpenses = _box.values
        .where(
          (expense) =>
              expense.amount >= lowerAmount && expense.amount <= upperAmount,
        )
        .toList();

    return filteredExpenses.map(_toDomainModel).toList();
  }

  /// Get total amount of all expenses
  Future<double> getTotalAmount() async {
    final expenses = _box.values.toList();
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Clear all expenses
  Future<void> clearAllExpenses() async {
    await _box.clear();
  }
}
