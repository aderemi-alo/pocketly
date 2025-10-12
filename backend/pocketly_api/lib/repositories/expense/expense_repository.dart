import 'package:drift/drift.dart';
import 'package:pocketly_api/database/database.dart';

/// Repository for expense CRUD operations
class ExpenseRepository {
  /// Creates an instance of [ExpenseRepository]
  const ExpenseRepository(this._db);

  final PocketlyDatabase _db;

  /// Gets an expense by ID
  Future<Expense?> findById(String expenseId) async {
    return (_db.select(_db.expenses)..where((e) => e.id.equals(expenseId)))
        .getSingleOrNull();
  }

  /// Creates a new expense
  Future<Expense> createExpense({
    required String userId,
    required String name,
    required double amount,
    required DateTime date,
    String? categoryId,
    String? description,
  }) async {
    final now = DateTime.now();

    final companion = ExpensesCompanion.insert(
      userId: Value(userId),
      name: name,
      amount: amount,
      date: date,
      categoryId: Value(categoryId),
      description: Value(description),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.into(_db.expenses).insert(companion);

    // Fetch and return the newly created expense
    return (_db.select(_db.expenses)
          ..where((e) => e.userId.equals(userId))
          ..where((e) => e.name.equals(name))
          ..where((e) => e.date.equals(date))
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingle();
  }

  /// Updates an existing expense
  /// Returns true if the expense was updated, false if not found
  Future<bool> updateExpense({
    required String expenseId,
    required String userId,
    String? name,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? description,
  }) async {
    final updateCompanion = ExpensesCompanion(
      id: Value(expenseId),
      name: name != null ? Value(name) : const Value.absent(),
      amount: amount != null ? Value(amount) : const Value.absent(),
      date: date != null ? Value(date) : const Value.absent(),
      categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
      description:
          description != null ? Value(description) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    final updatedCount = await (_db.update(_db.expenses)
          ..where((e) => e.id.equals(expenseId))
          ..where((e) => e.userId.equals(userId)))
        .write(updateCompanion);

    return updatedCount > 0;
  }

  /// Deletes an expense
  /// Returns true if the expense was deleted, false if not found
  Future<bool> deleteExpense({
    required String expenseId,
    required String userId,
  }) async {
    final deletedCount = await (_db.delete(_db.expenses)
          ..where((e) => e.id.equals(expenseId))
          ..where((e) => e.userId.equals(userId)))
        .go();

    return deletedCount > 0;
  }
}
