import 'package:drift/drift.dart';
import 'package:pocketly_api/database/database.dart';

/// Repository for expense CRUD operations
class ExpenseRepository {
  /// Creates an instance of [ExpenseRepository]
  const ExpenseRepository(this._db);

  final PocketlyDatabase _db;

  /// Gets an expense by ID (excludes deleted)
  Future<Expense?> findById(String expenseId) async {
    return (_db.select(_db.expenses)
          ..where((e) => e.id.equals(expenseId))
          ..where((e) => e.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Gets an expense by ID including deleted (for sync)
  Future<Expense?> findByIdForSync(String expenseId) async {
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
    String currency = 'NGN',
  }) async {
    final now = DateTime.now();

    final companion = ExpensesCompanion.insert(
      userId: Value(userId),
      name: name,
      amount: amount,
      date: date,
      categoryId: Value(categoryId),
      description: Value(description),
      currency: Value(currency),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.into(_db.expenses).insert(companion);

    // Fetch and return the newly created expense
    return (_db.select(_db.expenses)
          ..where((e) => e.userId.equals(userId))
          ..where((e) => e.name.equals(name))
          ..where((e) => e.date.equals(date))
          ..where((e) => e.isDeleted.equals(false))
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
    String? currency,
  }) async {
    final updateCompanion = ExpensesCompanion(
      id: Value(expenseId),
      name: name != null ? Value(name) : const Value.absent(),
      amount: amount != null ? Value(amount) : const Value.absent(),
      date: date != null ? Value(date) : const Value.absent(),
      categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
      description:
          description != null ? Value(description) : const Value.absent(),
      currency: currency != null ? Value(currency) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    final updatedCount = await (_db.update(_db.expenses)
          ..where((e) => e.id.equals(expenseId))
          ..where((e) => e.userId.equals(userId)))
        .write(updateCompanion);

    return updatedCount > 0;
  }

  /// Soft deletes an expense (sets isDeleted = true)
  /// Returns true if the expense was deleted, false if not found
  Future<bool> deleteExpense({
    required String expenseId,
    required String userId,
  }) async {
    final now = DateTime.now();
    final updateCompanion = ExpensesCompanion(
      id: Value(expenseId),
      isDeleted: const Value(true),
      updatedAt: Value(now),
    );

    final updatedCount = await (_db.update(_db.expenses)
          ..where((e) => e.id.equals(expenseId))
          ..where((e) => e.userId.equals(userId)))
        .write(updateCompanion);

    return updatedCount > 0;
  }

  /// Restores a soft-deleted expense
  /// Returns true if the expense was restored, false if not found
  Future<bool> restoreExpense({
    required String expenseId,
    required String userId,
  }) async {
    final now = DateTime.now();
    final updateCompanion = ExpensesCompanion(
      id: Value(expenseId),
      isDeleted: const Value(false),
      updatedAt: Value(now),
    );

    final updatedCount = await (_db.update(_db.expenses)
          ..where((e) => e.id.equals(expenseId))
          ..where((e) => e.userId.equals(userId)))
        .write(updateCompanion);

    return updatedCount > 0;
  }

  /// Gets all expenses for a user for sync (includes deleted items)
  /// Returns expenses modified after lastSyncAt
  Future<List<Expense>> getExpensesForSync({
    required String userId,
    DateTime? lastSyncAt,
  }) async {
    final query = _db.select(_db.expenses)
      ..where((e) => e.userId.equals(userId));

    if (lastSyncAt != null) {
      query.where((e) => e.updatedAt.isBiggerOrEqualValue(lastSyncAt));
    }

    query.orderBy([
      (e) => OrderingTerm(expression: e.updatedAt, mode: OrderingMode.asc),
    ]);

    return query.get();
  }
}
