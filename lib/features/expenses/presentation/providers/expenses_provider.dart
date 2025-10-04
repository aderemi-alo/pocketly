import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class ExpensesNotifier extends Notifier<ExpensesState> {
  @override
  ExpensesState build() {
    return const ExpensesState();
  }

  /// Add expense with validation
  void addExpense({
    required String name,
    String? description,
    required double amount,
    required Category category,
    required DateTime date,
  }) {
    // Simple validation
    if (name.trim().isEmpty) {
      setError('Expense name is required');
      return;
    }

    if (amount <= 0) {
      setError('Amount must be greater than 0');
      return;
    }

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      amount: amount,
      category: category,
      date: date,
      description: description,
    );

    state = state.copyWith(expenses: [...state.expenses, expense]);
  }

  /// Update expense with validation
  void updateExpense({
    required String expenseId,
    required String name,
    String? description,
    required double amount,
    required Category category,
    required DateTime date,
  }) {
    // Simple validation
    if (name.trim().isEmpty) {
      setError('Expense name is required');
      return;
    }

    if (amount <= 0) {
      setError('Amount must be greater than 0');
      return;
    }

    final updatedExpense = Expense(
      id: expenseId,
      name: name.trim(),
      amount: amount,
      category: category,
      date: date,
      description: description,
    );

    final updatedExpenses = state.expenses.map((expense) {
      return expense.id == expenseId ? updatedExpense : expense;
    }).toList();

    state = state.copyWith(expenses: updatedExpenses);
  }

  void deleteExpense(String expenseId) {
    final updatedExpenses = state.expenses
        .where((expense) => expense.id != expenseId)
        .toList();

    state = state.copyWith(expenses: updatedExpenses);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  // Get expenses by category
  List<Expense> getExpensesByCategory(String categoryId) {
    return state.expenses
        .where((expense) => expense.category.id == categoryId)
        .toList();
  }

  // Get expenses by date range
  List<Expense> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return state.expenses.where((expense) {
      return expense.date.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          expense.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get total amount by category
  double getTotalAmountByCategory(String categoryId) {
    return getExpensesByCategory(
      categoryId,
    ).fold(0.0, (sum, expense) => sum + expense.amount);
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, ExpensesState>(() {
  return ExpensesNotifier();
});
