import 'package:drift/drift.dart';
import 'package:pocketly_api/database/database.dart';

/// Repository for expense analytics and aggregations
class ExpenseAnalyticsRepository {
  /// Creates an instance of [ExpenseAnalyticsRepository]
  const ExpenseAnalyticsRepository(this._db);

  final PocketlyDatabase _db;

  /// Private helper method for summing expenses with flexible filters
  Future<double> _sumExpenses({
    required String userId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.amount.sum()])
      ..where(_db.expenses.userId.equals(userId))
      ..where(_db.expenses.isDeleted.equals(false));

    // Apply optional filters
    if (categoryId != null) {
      query.where(_db.expenses.categoryId.equals(categoryId));
    }

    if (startDate != null) {
      query.where(_db.expenses.date.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      query.where(_db.expenses.date.isSmallerOrEqualValue(endDate));
    }

    final result = await query.getSingle();
    return result.read(_db.expenses.amount.sum()) ?? 0.0;
  }

  /// Gets total amount of all expenses for a user
  Future<double> getTotalExpensesAmount(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _sumExpenses(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Gets total amount for a specific category
  Future<double> getTotalForCategory({
    required String userId,
    required String categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _sumExpenses(
      userId: userId,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Gets category breakdown (total amount per category)
  Future<Map<String, double>> getCategoryBreakdown({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.categoryId, _db.expenses.amount.sum()])
      ..where(_db.expenses.userId.equals(userId))
      ..where(_db.expenses.isDeleted.equals(false))
      ..where(_db.expenses.categoryId.isNotNull())
      ..groupBy([_db.expenses.categoryId]);

    // Apply optional date filters
    if (startDate != null) {
      query.where(_db.expenses.date.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      query.where(_db.expenses.date.isSmallerOrEqualValue(endDate));
    }

    final results = await query.get();

    final breakdown = <String, double>{};
    for (final row in results) {
      final categoryId = row.read(_db.expenses.categoryId);
      final total = row.read(_db.expenses.amount.sum());
      if (categoryId != null && total != null) {
        breakdown[categoryId] = total;
      }
    }

    return breakdown;
  }
}
