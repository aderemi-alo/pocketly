import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pocketly/core/services/logger_service.dart';
import 'package:pocketly/core/utils/icon_mapper.dart';
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
          icon: IconMapper.getIcon(expenseHive.categoryIconCodePoint),
          color: Color(expenseHive.categoryColorValue),
          updatedAt: DateTime.now(), // Category updatedAt not stored in ExpenseHive
          isDeleted: false,
        ),
        updatedAt: expenseHive.updatedAt,
        isDeleted: expenseHive.isDeleted,
      );
    } catch (e) {
      AppLogger.error('Failed to convert ExpenseHive to Expense domain model', e);
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
        updatedAt: expense.updatedAt,
        isDeleted: expense.isDeleted,
      );
    } catch (e) {
      AppLogger.error('Failed to convert Expense domain model to ExpenseHive', e);
      rethrow;
    }
  }

  /// Get all expenses (excluding deleted)
  Future<List<Expense>> getAllExpenses() async {
    final expenses = _box.values
        .where((e) => !e.isDeleted)
        .toList();
    return expenses.map(_toDomainModel).toList();
  }

  /// Get all expenses for sync (including deleted)
  Future<List<Expense>> getAllExpensesForSync() async {
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
      // Ensure updatedAt is set
      final expenseWithTimestamp = expense.copyWith(
        updatedAt: expense.updatedAt.isBefore(DateTime.now().subtract(const Duration(seconds: 1)))
            ? DateTime.now()
            : expense.updatedAt,
      );
      final expenseHive = _toHiveModel(expenseWithTimestamp);
      await _box.add(expenseHive);
    } catch (e) {
      AppLogger.error('Failed to add expense', e);
      rethrow;
    }
  }

  /// Update existing expense
  Future<void> updateExpense(Expense expense) async {
    final existingExpense = _box.values
        .where((e) => e.expenseId == expense.id)
        .firstOrNull;

    if (existingExpense != null) {
      // Ensure updatedAt is set to now if not provided
      final expenseWithTimestamp = expense.copyWith(
        updatedAt: expense.updatedAt.isBefore(DateTime.now().subtract(const Duration(seconds: 1)))
            ? DateTime.now()
            : expense.updatedAt,
      );
      final updatedExpense = _toHiveModel(expenseWithTimestamp);
      final index = _box.values.toList().indexOf(existingExpense);
      await _box.putAt(index, updatedExpense);
    }
  }

  /// Soft delete expense (sets isDeleted = true)
  Future<void> deleteExpense(String expenseId) async {
    final expense = _box.values
        .where((e) => e.expenseId == expenseId)
        .firstOrNull;

    if (expense != null) {
      final index = _box.values.toList().indexOf(expense);
      // Soft delete: set isDeleted = true and update updatedAt
      final deletedExpense = ExpenseHive.create(
        expenseId: expense.expenseId,
        name: expense.name,
        amount: expense.amount,
        date: expense.date,
        description: expense.description,
        categoryId: expense.categoryId,
        categoryName: expense.categoryName,
        categoryIcon: IconMapper.getIcon(expense.categoryIconCodePoint),
        categoryColor: Color(expense.categoryColorValue),
        updatedAt: DateTime.now(),
        isDeleted: true,
      );
      await _box.putAt(index, deletedExpense);
    }
  }

  /// Replace expense ID (atomic operation for local to server ID mapping)
  Future<void> replaceExpenseId(String oldId, String newId) async {
    final expense = _box.values
        .where((e) => e.expenseId == oldId)
        .firstOrNull;
    
    if (expense != null) {
      final index = _box.values.toList().indexOf(expense);
      // Create updated expense with new ID
      final updated = ExpenseHive.create(
        expenseId: newId,
        name: expense.name,
        amount: expense.amount,
        date: expense.date,
        categoryId: expense.categoryId,
        categoryName: expense.categoryName,
        categoryIcon: IconMapper.getIcon(expense.categoryIconCodePoint),
        categoryColor: Color(expense.categoryColorValue),
        description: expense.description,
        updatedAt: expense.updatedAt,
        isDeleted: expense.isDeleted,
      );
      // Single atomic operation: replace at same index
      await _box.putAt(index, updated);
    }
  }

  /// Get expenses by date range (excluding deleted)
  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final filteredExpenses = _box.values
        .where(
          (expense) =>
              !expense.isDeleted &&
              expense.date.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              expense.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();

    return filteredExpenses.map(_toDomainModel).toList();
  }

  /// Get expenses by category (excluding deleted)
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final filteredExpenses = _box.values
        .where((expense) => !expense.isDeleted && expense.categoryId == categoryId)
        .toList();

    return filteredExpenses.map(_toDomainModel).toList();
  }

  /// Get expenses by amount range (excluding deleted)
  Future<List<Expense>> getExpenseByAmount(
    double lowerAmount,
    double upperAmount,
  ) async {
    final filteredExpenses = _box.values
        .where(
          (expense) =>
              !expense.isDeleted &&
              expense.amount >= lowerAmount && expense.amount <= upperAmount,
        )
        .toList();

    return filteredExpenses.map(_toDomainModel).toList();
  }

  /// Get total amount of all expenses (excluding deleted)
  Future<double> getTotalAmount() async {
    final expenses = _box.values.where((e) => !e.isDeleted).toList();
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Clear all expenses
  Future<void> clearAllExpenses() async {
    await _box.clear();
  }
}
