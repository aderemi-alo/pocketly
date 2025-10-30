import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';
import 'package:pocketly/core/providers/app_state_provider.dart';
import 'package:pocketly/core/services/sync/sync_queue_service.dart';
import 'package:pocketly/core/services/sync/sync_models.dart';

class ExpensesNotifier extends Notifier<ExpensesState> {
  @override
  ExpensesState build() {
    // Initialize with loading state and load data after build completes
    Future.microtask(() => _loadExpenses());
    return const ExpensesState(isLoading: true);
  }

  /// Load expenses from Hive database
  Future<void> _loadExpenses() async {
    try {
      setLoading(true);
      final expenses = await expenseHiveRepository.getAllExpenses();
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      setError('Failed to load expenses: $e');
    }
  }

  /// Add expense with validation
  Future<void> addExpense({
    required String name,
    String? description,
    required double amount,
    required Category category,
    required DateTime date,
  }) async {
    // Simple validation
    if (name.trim().isEmpty) {
      setError('Expense name is required');
      return;
    }

    if (amount <= 0) {
      setError('Amount must be greater than 0');
      return;
    }

    // Check email verification limits
    final authState = ref.read(authProvider);
    final isVerified = authState.user?.isEmailVerified ?? true;
    final expenseCount = state.expenses.length;

    if (!isVerified) {
      if (expenseCount >= 20) {
        // Block at 21st expense
        setError('Verify your email to add more expenses');
        // Show dialog prompting verification
        _showVerificationDialog();
        return;
      } else if (expenseCount >= 14) {
        // Warning at 15th expense
        _showWarningSnackbar();
      }
    }

    try {
      setLoading(true);
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        amount: amount,
        category: category,
        date: date,
        description: description,
      );

      // Update state immediately for UI responsiveness
      final updatedExpenses = [...state.expenses, expense];
      state = state.copyWith(expenses: updatedExpenses, isLoading: false);

      // Persist to database in background
      await expenseHiveRepository.addExpense(expense);

      // Try to sync if authenticated, otherwise queue for later
      await _handleSyncForExpense(expense, SyncOperation.create);
    } catch (e) {
      setError('Failed to add expense: $e');
    }
  }

  /// Update filter
  void updateFilter(ExpenseFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Update expense with validation
  Future<void> updateExpense({
    required String expenseId,
    required String name,
    String? description,
    required double amount,
    required Category category,
    required DateTime date,
  }) async {
    // Simple validation
    if (name.trim().isEmpty) {
      setError('Expense name is required');
      return;
    }

    if (amount <= 0) {
      setError('Amount must be greater than 0');
      return;
    }

    try {
      setLoading(true);
      final updatedExpense = Expense(
        id: expenseId,
        name: name.trim(),
        amount: amount,
        category: category,
        date: date,
        description: description,
      );

      // Update state immediately for UI responsiveness
      final updatedExpenses = state.expenses.map((expense) {
        return expense.id == expenseId ? updatedExpense : expense;
      }).toList();
      state = state.copyWith(expenses: updatedExpenses, isLoading: false);

      // Persist to database in background
      await expenseHiveRepository.updateExpense(updatedExpense);

      // Try to sync if authenticated, otherwise queue for later
      await _handleSyncForExpense(updatedExpense, SyncOperation.update);
    } catch (e) {
      setError('Failed to update expense: $e');
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      setLoading(true);

      // Update state immediately for UI responsiveness
      final updatedExpenses = state.expenses
          .where((expense) => expense.id != expenseId)
          .toList();
      state = state.copyWith(expenses: updatedExpenses, isLoading: false);

      // Persist to database in background
      await expenseHiveRepository.deleteExpense(expenseId);

      // Try to sync if authenticated, otherwise queue for later
      await _handleSyncForDelete(expenseId);
    } catch (e) {
      setError('Failed to delete expense: $e');
    }
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void _showWarningSnackbar() {
    // This will be handled by the UI layer
    // The warning will be shown as a snackbar in the add expense view
  }

  void _showVerificationDialog() {
    // This will be handled by the UI layer
    // The dialog will be shown in the add expense view
  }

  // Get expenses by category
  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    return await expenseHiveRepository.getExpensesByCategory(categoryId);
  }

  // Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await expenseHiveRepository.getExpensesByDateRange(
      startDate,
      endDate,
    );
  }

  // Get expenses by amount
  Future<List<Expense>> getExpensesByAmount(
    double lowerAmount,
    double upperAmount,
  ) async {
    return await expenseHiveRepository.getExpenseByAmount(
      lowerAmount,
      upperAmount,
    );
  }

  // Get total amount by category
  Future<double> getTotalAmountByCategory(String categoryId) async {
    final expenses = await getExpensesByCategory(categoryId);
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  // Refresh expenses from database
  Future<void> refreshExpenses() async {
    await _loadExpenses();
  }

  /// Persist current state to database without affecting UI
  /// Handle sync for expense operations
  Future<void> _handleSyncForExpense(
    Expense expense,
    SyncOperation operation,
  ) async {
    try {
      final appState = ref.read(appStateProvider);

      if (appState.canSync) {
        // Try to sync immediately if authenticated
        // TODO: Implement actual sync logic here
        debugPrint('Syncing expense: ${expense.name}');
      } else {
        // Queue for later sync
        final syncQueue = locator<SyncQueueService>();
        await syncQueue.enqueue(
          entityType: 'expense',
          operation: operation,
          data: {
            'id': expense.id,
            'name': expense.name,
            'amount': expense.amount,
            'date': expense.date.toIso8601String(),
            'categoryId': expense.category.id,
            'description': expense.description,
          },
        );

        // Update pending sync count
        final pendingCount = await syncQueue.getPendingItems().length;
        ref
            .read(appStateProvider.notifier)
            .updatePendingSyncCount(pendingCount);
      }
    } catch (e) {
      // Don't fail the operation if sync fails
      debugPrint('Failed to sync expense: $e');
    }
  }

  /// Handle sync for expense deletion
  Future<void> _handleSyncForDelete(String expenseId) async {
    try {
      final appState = ref.read(appStateProvider);

      if (appState.canSync) {
        // Try to sync immediately if authenticated
        // TODO: Implement actual sync logic here
        debugPrint('Syncing expense deletion: $expenseId');
      } else {
        // Queue for later sync
        final syncQueue = locator<SyncQueueService>();
        await syncQueue.enqueue(
          entityType: 'expense',
          operation: SyncOperation.delete,
          data: {'id': expenseId},
        );

        // Update pending sync count
        final pendingCount = await syncQueue.getPendingItems().length;
        ref
            .read(appStateProvider.notifier)
            .updatePendingSyncCount(pendingCount);
      }
    } catch (e) {
      // Don't fail the operation if sync fails
      debugPrint('Failed to sync expense deletion: $e');
    }
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, ExpensesState>(() {
  return ExpensesNotifier();
});
