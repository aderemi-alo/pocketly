import 'package:drift/drift.dart';
import 'package:pocketly_api/database/database.dart';

/// Repository for expense query operations
class ExpenseQueryRepository {
  /// Creates an instance of [ExpenseQueryRepository]
  const ExpenseQueryRepository(this._db);

  final PocketlyDatabase _db;

  /// Flexible query method to find expenses with various filters
  Future<List<Expense>> findExpenses({
    required String userId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? page,
    String? sortBy = 'date',
    String? sortOrder = 'desc',
  }) async {
    final query = _db.select(_db.expenses)
      ..where((e) => e.userId.equals(userId));

    // Apply optional filters
    if (categoryId != null) {
      query.where((e) => e.categoryId.equals(categoryId));
    }

    if (startDate != null) {
      query.where((e) => e.date.isBiggerOrEqualValue(startDate));
    }

    if (endDate != null) {
      query.where((e) => e.date.isSmallerOrEqualValue(endDate));
    }

    // Order by sortBy and sortOrder
    query.orderBy([
      (e) => OrderingTerm(
            expression: sortBy == 'date' ? e.date : e.amount,
            mode: sortOrder == 'desc' ? OrderingMode.desc : OrderingMode.asc,
          ),
    ]);

    // Apply pagination
    if (limit != null) {
      query.limit(limit, offset: page != null ? (page - 1) * limit : 0);
    }

    return query.get();
  }

  /// Gets count of user's expenses with optional filters
  Future<int> getExpensesCount({
    required String userId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.id.count()])
      ..where(_db.expenses.userId.equals(userId));

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
    return result.read(_db.expenses.id.count()) ?? 0;
  }

  /// Gets expense with its category details
  Future<(Expense, Category?)?> getExpenseWithCategory(
    String expenseId,
  ) async {
    final query = _db.select(_db.expenses).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.expenses.categoryId),
      ),
    ])
      ..where(_db.expenses.id.equals(expenseId));

    final result = await query.getSingleOrNull();

    if (result == null) return null;

    final expense = result.readTable(_db.expenses);
    final category = result.readTableOrNull(_db.categories);

    return (expense, category);
  }

  /// Gets expenses with their category details
  Future<List<(Expense, Category?)>> getExpensesWithCategories({
    required String userId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? page,
    String? sortBy = 'date',
    String? sortOrder = 'desc',
  }) async {
    final query = _db.select(_db.expenses).join([
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.expenses.categoryId),
      ),
    ])
      ..where(_db.expenses.userId.equals(userId))
      ..orderBy([
        OrderingTerm(
          expression:
              sortBy == 'date' ? _db.expenses.date : _db.expenses.amount,
          mode: sortOrder == 'desc' ? OrderingMode.desc : OrderingMode.asc,
        ),
      ]);

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

    // Apply pagination
    if (limit != null) {
      query.limit(limit, offset: page != null ? (page - 1) * limit : 0);
    }

    final results = await query.get();

    return results.map((result) {
      final expense = result.readTable(_db.expenses);
      final category = result.readTableOrNull(_db.categories);
      return (expense, category);
    }).toList();
  }
}
