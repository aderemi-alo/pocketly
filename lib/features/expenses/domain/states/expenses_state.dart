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
