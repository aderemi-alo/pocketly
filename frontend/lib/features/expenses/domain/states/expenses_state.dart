import 'package:pocketly/features/features.dart';

enum ExpenseSyncStatus { idle, syncing, success, failed, queued }

class ExpensesState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;
  final ExpenseFilter filter;
  final ExpenseSyncStatus syncStatus;
  final String? lastSyncError;
  final bool isQueued;
  final Map<String, ExpenseSyncStatus> expenseSyncStatuses;

  const ExpensesState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
    this.filter = const ExpenseFilter(),
    this.syncStatus = ExpenseSyncStatus.idle,
    this.lastSyncError,
    this.isQueued = false,
    this.expenseSyncStatuses = const {},
  });

  ExpensesState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
    ExpenseFilter? filter,
    ExpenseSyncStatus? syncStatus,
    String? lastSyncError,
    bool? isQueued,
    Map<String, ExpenseSyncStatus>? expenseSyncStatuses,
    bool clearSyncError = false,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      filter: filter ?? this.filter,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncError: clearSyncError
          ? null
          : (lastSyncError ?? this.lastSyncError),
      isQueued: isQueued ?? this.isQueued,
      expenseSyncStatuses: expenseSyncStatuses ?? this.expenseSyncStatuses,
    );
  }

  double get totalAmount {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get totalAmountLast30Days {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return expenses
        .where((expense) => expense.date.isAfter(thirtyDaysAgo))
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get totalAmountCurrentMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);

    return expenses
        .where(
          (expense) =>
              expense.date.isAfter(startOfMonth) ||
              expense.date.isAtSameMomentAs(startOfMonth),
        )
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  int get transactionCountCurrentMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);

    return expenses
        .where(
          (expense) =>
              expense.date.isAfter(startOfMonth) ||
              expense.date.isAtSameMomentAs(startOfMonth),
        )
        .length;
  }

  List<Expense> get expensesByDate {
    final sortedExpenses = List<Expense>.from(expenses);
    sortedExpenses.sort((a, b) => b.date.compareTo(a.date));
    return sortedExpenses;
  }

  Map<String, List<Expense>> get expensesByCategory {
    final Map<String, List<Expense>> grouped = {};
    for (final expense in expenses) {
      final categoryId = expense.category.id;
      if (grouped[categoryId] == null) {
        grouped[categoryId] = [];
      }
      grouped[categoryId]!.add(expense);
    }
    return grouped;
  }

  Map<String, List<Expense>> get expensesByCategoryLast30Days {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final Map<String, List<Expense>> grouped = {};
    for (final expense in expenses) {
      if (expense.date.isAfter(thirtyDaysAgo)) {
        final categoryId = expense.category.id;
        if (grouped[categoryId] == null) {
          grouped[categoryId] = [];
        }
        grouped[categoryId]!.add(expense);
      }
    }
    return grouped;
  }

  Map<String, List<Expense>> get expensesByCategoryCurrentMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);

    final Map<String, List<Expense>> grouped = {};
    for (final expense in expenses) {
      if (expense.date.isAfter(startOfMonth) ||
          expense.date.isAtSameMomentAs(startOfMonth)) {
        final categoryId = expense.category.id;
        if (grouped[categoryId] == null) {
          grouped[categoryId] = [];
        }
        grouped[categoryId]!.add(expense);
      }
    }
    return grouped;
  }

  Map<String, List<Expense>> get expensesByMonth {
    final Map<String, List<Expense>> grouped = {};
    for (final expense in expenses) {
      final monthKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      if (grouped[monthKey] == null) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(expense);
    }

    // Sort each month's expenses by date (newest first)
    for (final monthExpenses in grouped.values) {
      monthExpenses.sort((a, b) => b.date.compareTo(a.date));
    }

    return grouped;
  }

  /// Get filtered expenses based on current filter
  List<Expense> get filteredExpenses {
    List<Expense> filtered = List.from(expenses);

    // Filter by category
    if (filter.selectedCategory != null) {
      filtered = filtered
          .where((expense) => expense.category.name == filter.selectedCategory)
          .toList();
    }

    // Filter by month (this_month, last_month, or custom date range)
    if (filter.selectedMonth == 'this_month') {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);
      filtered = filtered
          .where(
            (expense) =>
                expense.date.isAfter(
                  startOfMonth.subtract(const Duration(days: 1)),
                ) &&
                expense.date.isBefore(endOfMonth.add(const Duration(days: 1))),
          )
          .toList();
    } else if (filter.selectedMonth == 'last_month') {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1);
      final startOfLastMonth = DateTime(lastMonth.year, lastMonth.month);
      final endOfLastMonth = DateTime(lastMonth.year, lastMonth.month + 1, 0);
      filtered = filtered
          .where(
            (expense) =>
                expense.date.isAfter(
                  startOfLastMonth.subtract(const Duration(days: 1)),
                ) &&
                expense.date.isBefore(
                  endOfLastMonth.add(const Duration(days: 1)),
                ),
          )
          .toList();
    }

    // Filter by date range
    if (filter.startDate != null) {
      filtered = filtered
          .where(
            (expense) =>
                expense.date.isAfter(filter.startDate!) ||
                expense.date.isAtSameMomentAs(filter.startDate!),
          )
          .toList();
    }

    if (filter.endDate != null) {
      final endOfDay = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23,
        59,
        59,
      );
      filtered = filtered
          .where(
            (expense) =>
                expense.date.isBefore(endOfDay) ||
                expense.date.isAtSameMomentAs(endOfDay),
          )
          .toList();
    }

    // Filter by search query
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      filtered = filtered.where((expense) {
        final name = expense.name.toLowerCase();
        final description = expense.description?.toLowerCase() ?? '';
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  /// Get filtered expenses grouped by month
  Map<String, List<Expense>> get filteredExpensesByMonth {
    final Map<String, List<Expense>> grouped = {};
    for (final expense in filteredExpenses) {
      final monthKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      if (grouped[monthKey] == null) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(expense);
    }

    // Sort each month's expenses by date (newest first)
    for (final monthExpenses in grouped.values) {
      monthExpenses.sort((a, b) => b.date.compareTo(a.date));
    }

    return grouped;
  }

  /// Get available months for filtering
  List<String> get availableMonths {
    final months = <String>{};
    for (final expense in expenses) {
      final monthKey =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      months.add(monthKey);
    }

    final sortedMonths = months.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first

    return sortedMonths;
  }

  Map<String, double> get expensesByDayCurrentWeek {
    final now = DateTime.now();

    // Get the start of the current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    // Initialize map with all 7 days of the week
    final Map<String, double> grouped = {};
    for (int i = 0; i < 7; i++) {
      final date = startOfWeekDate.add(Duration(days: i));
      final dayKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      grouped[dayKey] = 0.0;
    }

    // Sum expenses for each day
    for (final expense in expenses) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );

      if (expenseDate.isAfter(
            startOfWeekDate.subtract(const Duration(days: 1)),
          ) &&
          expenseDate.isBefore(startOfWeekDate.add(const Duration(days: 7)))) {
        final dayKey =
            '${expenseDate.year}-${expenseDate.month.toString().padLeft(2, '0')}-${expenseDate.day.toString().padLeft(2, '0')}';
        grouped[dayKey] = (grouped[dayKey] ?? 0.0) + expense.amount;
      }
    }

    return grouped;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpensesState &&
        other.expenses.length == expenses.length &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.filter == filter &&
        other.syncStatus == syncStatus &&
        other.lastSyncError == lastSyncError &&
        other.isQueued == isQueued &&
        other.expenseSyncStatuses.length == expenseSyncStatuses.length;
  }

  @override
  int get hashCode => Object.hash(
    expenses,
    isLoading,
    error,
    filter,
    syncStatus,
    lastSyncError,
    isQueued,
    expenseSyncStatuses,
  );

  @override
  String toString() =>
      'ExpensesState(expenses: ${expenses.length}, isLoading: $isLoading, error: $error)';
}
