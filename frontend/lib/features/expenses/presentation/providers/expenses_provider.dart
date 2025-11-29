import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

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
      final now = DateTime.now();
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        amount: amount,
        category: category,
        date: date,
        description: description,
        updatedAt: now,
        isDeleted: false,
      );

      // Update state immediately for UI responsiveness
      final updatedExpenses = [...state.expenses, expense];
      state = state.copyWith(expenses: updatedExpenses, isLoading: false);

      // Persist to database in background
      await expenseHiveRepository.addExpense(expense);

      // Try to create on server if authenticated
      await _createExpenseOnServer(expense);
    } catch (e) {
      setError('Failed to add expense: $e');
    }
  }

  /// Update filter
  void updateFilter(ExpenseFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Search expenses
  void searchExpenses(String query) {
    final currentFilter = state.filter;
    final updatedFilter = currentFilter.copyWith(searchQuery: query);
    state = state.copyWith(filter: updatedFilter);
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
      // Get existing expense to preserve updatedAt if needed, or set to now
      final existingExpense = state.expenses.firstWhere(
        (e) => e.id == expenseId,
        orElse: () => Expense(
          id: expenseId,
          name: name.trim(),
          amount: amount,
          category: category,
          date: date,
          description: description,
          updatedAt: DateTime.now(),
          isDeleted: false,
        ),
      );

      final updatedExpense = existingExpense.copyWith(
        name: name.trim(),
        amount: amount,
        category: category,
        date: date,
        description: description,
        updatedAt: DateTime.now(), // Update timestamp on modification
      );

      // Update state immediately for UI responsiveness
      final updatedExpenses = state.expenses.map((expense) {
        return expense.id == expenseId ? updatedExpense : expense;
      }).toList();
      state = state.copyWith(expenses: updatedExpenses, isLoading: false);

      // Persist to database in background
      await expenseHiveRepository.updateExpense(updatedExpense);

      // Try to update on server if authenticated
      await _updateExpenseOnServer(updatedExpense);
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

      // Try to delete on server if authenticated
      await _deleteExpenseOnServer(expenseId);
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

  /// Get backend category ID for a local category
  /// Maps predefined categories by name, or uses UUID directly for custom categories
  Future<String?> _getBackendCategoryId(Category localCategory) async {
    try {
      final categoriesNotifier = ref.read(categoriesProvider.notifier);

      // Try to find by name first (for predefined categories)
      final backendCategory = categoriesNotifier.getCategoryByName(
        localCategory.name,
      );

      if (backendCategory != null) {
        return backendCategory.id; // Backend UUID
      }

      // If not found by name, check if the ID is already a UUID (custom category)
      // UUIDs are typically 36 characters with dashes: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
      if (_isUUID(localCategory.id)) {
        // Verify it exists in our categories
        final categoryById = categoriesNotifier.getCategoryById(
          localCategory.id,
        );
        if (categoryById != null) {
          return localCategory.id;
        }
      }

      // Category not found - return null (expense will be created without category)
      AppLogger.warning(
        '⚠️ Category not found for sync: ${localCategory.name} (${localCategory.id})',
      );
      return null;
    } catch (e) {
      ErrorHandler.logError('Error getting backend category ID', e);
      return null;
    }
  }

  /// Check if a string is a valid UUID format
  bool _isUUID(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }

  /// Create expense on server (direct API call)
  Future<void> _createExpenseOnServer(Expense expense) async {
    try {
      final networkService = locator<NetworkService>();
      final isOnline = await networkService.isConnected;

      if (!isOnline) {
        throw Exception('No internet connection');
      }

      final expenseApi = expenseApiRepository;
      final localId = expense.id;

      // Get backend category ID
      final backendCategoryId = await _getBackendCategoryId(expense.category);

      // Create expense on server
      final apiExpense = await expenseApi.createExpense(
        name: expense.name,
        amount: expense.amount,
        date: expense.date,
        categoryId: backendCategoryId,
        description: expense.description,
      );

      // Update local expense with server ID
      final updatedExpense = Expense(
        id: apiExpense.id,
        name: apiExpense.name,
        amount: apiExpense.amount,
        date: apiExpense.date,
        category: expense.category,
        description: apiExpense.description,
        updatedAt: apiExpense.updatedAt,
        isDeleted: apiExpense.isDeleted ?? false,
      );

      // Update in Hive with server ID
      await expenseHiveRepository.replaceExpenseId(localId, apiExpense.id);

      // Update state with server ID
      final updatedExpenses = state.expenses.map((e) {
        return e.id == localId ? updatedExpense : e;
      }).toList();
      state = state.copyWith(expenses: updatedExpenses);

      AppLogger.info('✅ Created expense: ${expense.name} -> ${apiExpense.id}');
    } catch (e) {
      // Rollback UI and Hive on failure
      final updatedExpenses = state.expenses
          .where((exp) => exp.id != expense.id)
          .toList();
      await expenseHiveRepository.deleteExpense(expense.id);
      state = state.copyWith(expenses: updatedExpenses);
      rethrow;
    }
  }

  /// Update expense on server (direct API call)
  Future<void> _updateExpenseOnServer(Expense expense) async {
    try {
      final networkService = locator<NetworkService>();
      final isOnline = await networkService.isConnected;

      if (!isOnline) {
        throw Exception('No internet connection');
      }

      final expenseApi = expenseApiRepository;
      final backendCategoryId = await _getBackendCategoryId(expense.category);

      await expenseApi.updateExpense(
        expenseId: expense.id,
        name: expense.name,
        amount: expense.amount,
        date: expense.date,
        categoryId: backendCategoryId,
        description: expense.description,
      );

      AppLogger.info('✅ Updated expense: ${expense.name}');
    } catch (e) {
      // Reload from Hive to revert UI changes
      await _loadExpenses();
      rethrow;
    }
  }

  /// Delete expense on server (direct API call)
  Future<void> _deleteExpenseOnServer(String expenseId) async {
    try {
      final networkService = locator<NetworkService>();
      final isOnline = await networkService.isConnected;

      if (!isOnline) {
        throw Exception('No internet connection');
      }

      final expenseApi = expenseApiRepository;
      await expenseApi.deleteExpense(expenseId);

      AppLogger.info('✅ Deleted expense: $expenseId');
    } catch (e) {
      // Reload from Hive to revert UI changes
      await _loadExpenses();
      rethrow;
    }
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, ExpensesState>(() {
  return ExpensesNotifier();
});
