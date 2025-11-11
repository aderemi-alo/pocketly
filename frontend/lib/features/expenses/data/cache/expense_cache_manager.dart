import 'package:hive/hive.dart';
import 'package:pocketly/core/services/logger_service.dart';
import 'package:pocketly/features/expenses/data/models/expense_hive.dart';

class ExpenseCacheManager {
  static const int maxCacheSize = 100;
  static const String _cacheBoxName = 'expense_cache';

  Box<ExpenseHive> get _box => Hive.box<ExpenseHive>(_cacheBoxName);

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_cacheBoxName)) {
      await Hive.openBox<ExpenseHive>(_cacheBoxName);
    }
  }

  /// Add expense to cache with size limit
  Future<void> cacheExpense(ExpenseHive expense) async {
    // Check cache size
    if (_box.length >= maxCacheSize) {
      await _evictOldest();
    }

    await _box.put(expense.expenseId, expense);
    AppLogger.debug('💾 Cached expense: ${expense.expenseId}');
  }

  /// Cache multiple expenses
  Future<void> cacheExpenses(List<ExpenseHive> expenses) async {
    // Sort by date (most recent first)
    expenses.sort((a, b) => b.date.compareTo(a.date));

    // Take only the most recent up to cache limit
    final toCache = expenses.take(maxCacheSize).toList();

    // Clear existing cache
    await _box.clear();

    // Cache new items
    final cacheMap = <String, ExpenseHive>{
      for (final expense in toCache) expense.expenseId: expense,
    };

    await _box.putAll(cacheMap);
    AppLogger.debug('💾 Cached ${toCache.length} expenses');
  }

  /// Get cached expense by ID
  ExpenseHive? getCachedExpense(String expenseId) {
    return _box.get(expenseId);
  }

  /// Get all cached expenses
  List<ExpenseHive> getAllCachedExpenses() {
    final expenses = _box.values.toList();
    // Sort by date (most recent first)
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  /// Remove expense from cache
  Future<void> removeCachedExpense(String expenseId) async {
    await _box.delete(expenseId);
    AppLogger.debug('🗑️ Removed expense from cache: $expenseId');
  }

  /// Update cached expense
  Future<void> updateCachedExpense(ExpenseHive expense) async {
    await _box.put(expense.expenseId, expense);
    AppLogger.debug('✏️ Updated cached expense: ${expense.expenseId}');
  }

  /// Evict oldest expense from cache
  Future<void> _evictOldest() async {
    final expenses = _box.values.toList();
    if (expenses.isEmpty) return;

    // Find oldest expense by date
    expenses.sort((a, b) => a.date.compareTo(b.date));
    final oldest = expenses.first;

    await _box.delete(oldest.expenseId);
    AppLogger.debug(
      '♻️ Evicted oldest expense from cache: ${oldest.expenseId}',
    );
  }

  /// Clear entire cache
  Future<void> clearCache() async {
    await _box.clear();
    AppLogger.debug('🗑️ Cleared expense cache');
  }

  /// Get cache size
  int get cacheSize => _box.length;

  /// Check if cache is full
  bool get isFull => _box.length >= maxCacheSize;

  /// Get available cache slots
  int get availableSlots => maxCacheSize - _box.length;
}
