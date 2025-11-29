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

  /// Add expense with validation (backend-first approach)
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
    // final authState = ref.read(authProvider);
    // final isVerified = authState.user?.isEmailVerified ?? true;
    // final expenseCount = state.expenses.length;

    // if (!isVerified) {
    //   if (expenseCount >= 20) {
    //     // Block at 21st expense
    //     setError('Verify your email to add more expenses');
    //     // Show dialog prompting verification
    //     _showVerificationDialog();
    //     return;
    //   } else if (expenseCount >= 14) {
    //     // Warning at 15th expense
    //     _showWarningSnackbar();
    //   }
    // }

    try {
      setLoading(true);

      // BACKEND-FIRST: Create on server first
      final createdExpense = await _createExpenseOnBackend(
        name: name.trim(),
        description: description,
        amount: amount,
        category: category,
        date: date,
      );

      // Only update state and Hive after backend success
      final updatedExpenses = [...state.expenses, createdExpense];
      state = state.copyWith(expenses: updatedExpenses, isLoading: false);

      // Persist to database with backend-generated ID
      await expenseHiveRepository.addExpense(createdExpense);

      AppLogger.info('✅ Expense added successfully: ${createdExpense.id}');
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

  /// Update expense with validation (backend-first approach)
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

      // BACKEND-FIRST: Update on server first
      final updatedApiExpense = await _updateExpenseOnBackend(
        expenseId: expenseId,
        name: name.trim(),
        description: description,
        amount: amount,
        category: category,
        date: date,
      );

      // Only update state and Hive after backend success
      final updatedExpense = Expense(
        id: updatedApiExpense.id,
        name: updatedApiExpense.name,
        amount: updatedApiExpense.amount,
        category: category, // Preserve category from input
        date: updatedApiExpense.date,
        description: updatedApiExpense.description,
        updatedAt: updatedApiExpense.updatedAt,
        isDeleted: updatedApiExpense.isDeleted ?? false,
      );

      final updatedExpenses = state.expenses.map((expense) {
        return expense.id == expenseId ? updatedExpense : expense;
      }).toList();
      state = state.copyWith(expenses: updatedExpenses, isLoading: false);

      // Persist to database
      await expenseHiveRepository.updateExpense(updatedExpense);

      AppLogger.info('✅ Expense updated successfully: $expenseId');
    } catch (e) {
      setError('Failed to update expense: $e');
    }
  }

  /// Delete expense (backend-first approach)
  Future<void> deleteExpense(String expenseId) async {
    try {
      setLoading(true);

      // BACKEND-FIRST: Delete on server first
      await _deleteExpenseOnBackend(expenseId);

      // Only update state and Hive after backend success
      final updatedExpenses = state.expenses
          .where((expense) => expense.id != expenseId)
          .toList();
      state = state.copyWith(expenses: updatedExpenses, isLoading: false);

      // Persist to database
      await expenseHiveRepository.deleteExpense(expenseId);

      AppLogger.info('✅ Expense deleted successfully: $expenseId');
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

  /// Create expense on backend (returns created expense with backend ID)
  Future<Expense> _createExpenseOnBackend({
    required String name,
    String? description,
    required double amount,
    required Category category,
    required DateTime date,
  }) async {
    final networkService = locator<NetworkService>();
    final isOnline = await networkService.isConnected;

    if (!isOnline) {
      throw Exception(
        'No internet connection. Please connect to create expenses.',
      );
    }

    final expenseApi = expenseApiRepository;

    // Get backend category ID
    final backendCategoryId = await _getBackendCategoryId(category);

    // Create expense on server
    final apiExpense = await expenseApi.createExpense(
      name: name,
      amount: amount,
      date: date,
      categoryId: backendCategoryId,
      description: description,
    );

    // Return expense with backend-generated ID
    return Expense(
      id: apiExpense.id,
      name: apiExpense.name,
      amount: apiExpense.amount,
      date: apiExpense.date,
      category: category,
      description: apiExpense.description,
      updatedAt: apiExpense.updatedAt,
      isDeleted: apiExpense.isDeleted ?? false,
    );
  }

  /// Update expense on backend (returns updated expense data)
  Future<ExpenseApiModel> _updateExpenseOnBackend({
    required String expenseId,
    required String name,
    String? description,
    required double amount,
    required Category category,
    required DateTime date,
  }) async {
    final networkService = locator<NetworkService>();
    final isOnline = await networkService.isConnected;

    if (!isOnline) {
      throw Exception(
        'No internet connection. Please connect to update this expense.',
      );
    }

    final expenseApi = expenseApiRepository;
    final backendCategoryId = await _getBackendCategoryId(category);

    return await expenseApi.updateExpense(
      expenseId: expenseId,
      name: name,
      amount: amount,
      date: date,
      categoryId: backendCategoryId,
      description: description,
    );
  }

  /// Delete expense on backend
  Future<void> _deleteExpenseOnBackend(String expenseId) async {
    final networkService = locator<NetworkService>();
    final isOnline = await networkService.isConnected;

    if (!isOnline) {
      throw Exception(
        'No internet connection. Please connect to delete this expense.',
      );
    }

    final expenseApi = expenseApiRepository;
    await expenseApi.deleteExpense(expenseId);
  }

  /// Fetch expenses from backend and sync to local Hive database
  Future<void> fetchAndSyncExpenses() async {
    try {
      setLoading(true);
      final expenseApi = expenseApiRepository;

      // 1. Fetch all expenses from server
      final result = await expenseApi.getExpenses(
        limit: 1000, // Large enough to get all expenses for now
        offset: 0,
        includeCategory: true,
      );

      final apiExpenses = result['expenses'] as List<ExpenseApiModel>;

      // 2. Convert to domain models
      final List<Expense> domainExpenses = [];

      for (final apiExpense in apiExpenses) {
        // We need the category to be present
        if (apiExpense.category == null) {
          AppLogger.warning(
            'Skipping expense ${apiExpense.id} due to missing category',
          );
          continue;
        }

        domainExpenses.add(
          Expense(
            id: apiExpense.id,
            name: apiExpense.name,
            amount: apiExpense.amount,
            date: apiExpense.date,
            category: apiExpense.category!.toDomain(),
            description: apiExpense.description,
            updatedAt: apiExpense.updatedAt,
            isDeleted: apiExpense.isDeleted ?? false,
          ),
        );
      }

      // 3. Clear local database
      await expenseHiveRepository.clearAllExpenses();

      // 4. Populate local database with fresh data
      for (final expense in domainExpenses) {
        await expenseHiveRepository.addExpense(expense);
      }

      // 5. Update state
      state = state.copyWith(expenses: domainExpenses, isLoading: false);

      AppLogger.info(
        '✅ Successfully synced ${domainExpenses.length} expenses from server',
      );
    } catch (e) {
      ErrorHandler.logError('Failed to sync expenses from server', e);
      setError('Failed to sync expenses: $e');
    }
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, ExpensesState>(() {
  return ExpensesNotifier();
});
