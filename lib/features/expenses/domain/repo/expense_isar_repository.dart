import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pocketly/features/expenses/data/database/isar_database.dart';
import 'package:pocketly/features/expenses/data/models/expense_isar.dart';
import 'package:pocketly/features/expenses/domain/models/expense.dart';
import 'package:pocketly/features/expenses/domain/models/category.dart';

class ExpenseIsarRepository {
  Future<Isar> get _isar => IsarDatabase.instance;

  /// Convert ExpenseIsar to Expense domain model
  Expense _toDomainModel(ExpenseIsar expenseIsar) {
    try {
      return Expense(
        id: expenseIsar.expenseId,
        name: expenseIsar.name,
        amount: expenseIsar.amount,
        date: expenseIsar.date,
        description: expenseIsar.description,
        category: Category(
          id: expenseIsar.categoryId,
          name: expenseIsar.categoryName,
          icon: IconData(
            expenseIsar.categoryIconCodePoint,
            fontFamily: 'MaterialIcons',
          ),
          color: Color(expenseIsar.categoryColorValue),
        ),
      );
    } catch (e) {
      debugPrint('Failed to convert ExpenseIsar to Expense domain model: $e');
      rethrow;
    }
  }

  /// Convert Expense domain model to ExpenseIsar
  ExpenseIsar _toIsarModel(Expense expense) {
    try {
      return ExpenseIsar.create(
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
      debugPrint('Failed to convert Expense domain model to ExpenseIsar: $e');
      rethrow;
    }
  }

  /// Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    final isar = await _isar;
    final expenses = await isar.expenseIsars.where().findAll();
    return expenses.map(_toDomainModel).toList();
  }

  /// Get expense by ID
  Future<Expense?> getExpenseById(String expenseId) async {
    final isar = await _isar;
    final expense = await isar.expenseIsars
        .where()
        .expenseIdEqualTo(expenseId)
        .findFirst();

    return expense != null ? _toDomainModel(expense) : null;
  }

  /// Add new expense
  Future<void> addExpense(Expense expense) async {
    try {
      final isar = await _isar;
      final expenseIsar = _toIsarModel(expense);

      await isar.writeTxn(() async {
        await isar.expenseIsars.put(expenseIsar);
      });
    } catch (e) {
      debugPrint('Failed to add expense: $e');
      rethrow;
    }
  }

  /// Update existing expense
  Future<void> updateExpense(Expense expense) async {
    final isar = await _isar;
    final existingExpense = await isar.expenseIsars
        .where()
        .expenseIdEqualTo(expense.id)
        .findFirst();

    if (existingExpense != null) {
      final updatedExpense = _toIsarModel(expense);
      updatedExpense.id = existingExpense.id; // Keep the same Isar ID

      await isar.writeTxn(() async {
        await isar.expenseIsars.put(updatedExpense);
      });
    }
  }

  /// Delete expense
  Future<void> deleteExpense(String expenseId) async {
    final isar = await _isar;
    final expense = await isar.expenseIsars
        .where()
        .expenseIdEqualTo(expenseId)
        .findFirst();

    if (expense != null) {
      await isar.writeTxn(() async {
        await isar.expenseIsars.delete(expense.id);
      });
    }
  }

  /// Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final isar = await _isar;

    final filteredExpenses = await isar.expenseIsars
        .filter()
        .dateBetween(startDate, endDate)
        .findAll();

    return filteredExpenses.map(_toDomainModel).toList();
  }

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final isar = await _isar;

    // Filter by category manually since query methods aren't working
    final filteredExpenses = await isar.expenseIsars
        .filter()
        .categoryIdEqualTo(categoryId)
        .findAll();

    return filteredExpenses.map(_toDomainModel).toList();
  }

  Future<List<Expense>> getExpenseByAmount(
    double lowerAmount,
    double upperAmount,
  ) async {
    final isar = await _isar;
    final filteredExpenses = await isar.expenseIsars
        .filter()
        .amountBetween(lowerAmount, upperAmount)
        .findAll();

    return filteredExpenses.map(_toDomainModel).toList();
  }

  /// Get total amount of all expenses
  Future<double> getTotalAmount() async {
    final isar = await _isar;
    final expenses = await isar.expenseIsars.where().findAll();
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Clear all expenses
  Future<void> clearAllExpenses() async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.expenseIsars.clear();
    });
  }
}
