import 'package:pocketly/features/features.dart';

class ExpensesState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;

  const ExpensesState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  ExpensesState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(expenses, isLoading, error);

  @override
  String toString() =>
      'ExpensesState(expenses: ${expenses.length}, isLoading: $isLoading, error: $error)';
}
