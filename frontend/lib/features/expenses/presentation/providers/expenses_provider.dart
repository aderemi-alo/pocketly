import 'package:dio/dio.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/core/services/logger_service.dart';
import 'package:pocketly/core/utils/error_handler.dart';
import 'package:pocketly/features/features.dart';
import 'package:pocketly/core/providers/app_state_provider.dart';
import 'package:pocketly/core/services/sync/sync_queue_service.dart';
import 'package:pocketly/core/services/sync/sync_models.dart';

class ExpensesNotifier extends Notifier<ExpensesState> {
  bool _isPulling = false;

  @override
  ExpensesState build() {
    // Initialize with loading state and load data after build completes
    Future.microtask(() => _loadExpenses());
    return const ExpensesState(isLoading: true);
  }

  /// Load expenses from Hive database only (no sync trigger)
  Future<void> _loadExpensesFromHiveOnly() async {
    try {
      final expenses = await expenseHiveRepository.getAllExpenses();
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      ErrorHandler.logError('Failed to load expenses from Hive', e);
    }
  }

  /// Load expenses from Hive database
  Future<void> _loadExpenses() async {
    try {
      setLoading(true);
      final expenses = await expenseHiveRepository.getAllExpenses();
      state = state.copyWith(expenses: expenses, isLoading: false);

      // Smart background sync: only if authenticated, online, and stale
      final appState = ref.read(appStateProvider);
      final networkService = locator<NetworkService>();
      final isOnline = await networkService.isConnected;
      final lastSync = appState.lastSyncTime;
      final isSyncStale = lastSync == null || 
                          DateTime.now().difference(lastSync) > const Duration(minutes: 5);

      if (appState.canSync && isOnline && isSyncStale) {
        // Use flag to prevent recursive calls
        if (!_isPulling) {
          _isPulling = true;
          syncManager.pullExpensesFromServer().then((_) {
            // Reload only LOCAL data, don't trigger another pull
            _loadExpensesFromHiveOnly();
          }).catchError((e) {
            ErrorHandler.logError('Background pull sync failed', e);
          }).whenComplete(() {
            _isPulling = false;
          });
        }
      }
    } catch (e) {
      setError('Failed to load expenses: $e');
    }
  }

  /// Sync expenses from server
  Future<void> syncFromServer() async {
    try {
      setLoading(true);
      await syncManager.pullExpensesFromServer();
      // Reload expenses after sync
      await _loadExpenses();
    } catch (e) {
      setError('Failed to sync from server: $e');
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

  /// Update sync status for a specific expense
  void _updateExpenseSyncStatus(String expenseId, ExpenseSyncStatus status) {
    final updatedStatuses = Map<String, ExpenseSyncStatus>.from(state.expenseSyncStatuses);
    updatedStatuses[expenseId] = status;
    state = state.copyWith(expenseSyncStatuses: updatedStatuses);
  }

  /// Get sync status for a specific expense
  ExpenseSyncStatus getExpenseSyncStatus(String expenseId) {
    return state.expenseSyncStatuses[expenseId] ?? ExpenseSyncStatus.idle;
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
      final backendCategory = categoriesNotifier.getCategoryByName(localCategory.name);

      if (backendCategory != null) {
        return backendCategory.id; // Backend UUID
      }

      // If not found by name, check if the ID is already a UUID (custom category)
      // UUIDs are typically 36 characters with dashes: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
      if (_isUUID(localCategory.id)) {
        // Verify it exists in our categories
        final categoryById = categoriesNotifier.getCategoryById(localCategory.id);
        if (categoryById != null) {
          return localCategory.id;
        }
      }

      // Category not found - return null (expense will be created without category)
      AppLogger.warning('⚠️ Category not found for sync: ${localCategory.name} (${localCategory.id})');
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

  /// Persist current state to database without affecting UI
  /// Handle sync for expense operations
  Future<void> _handleSyncForExpense(
    Expense expense,
    SyncOperation operation,
  ) async {
    try {
      final appState = ref.read(appStateProvider);
      final networkService = locator<NetworkService>();
      final isOnline = await networkService.isConnected;

      // Set syncing status for this specific expense
      _updateExpenseSyncStatus(expense.id, ExpenseSyncStatus.syncing);

      if (appState.canSync && isOnline) {
        // Try to sync immediately if authenticated and online
        try {
          final expenseApi = expenseApiRepository;
          final localId = expense.id; // Store local ID for mapping

          // Get backend category ID
          final backendCategoryId = await _getBackendCategoryId(expense.category);

          if (operation == SyncOperation.create) {
            // Create expense on server
            // categoryId is optional - only include if we found a valid backend category
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
              category: expense.category, // Keep local category
              description: apiExpense.description,
            );

            // Update in Hive with server ID (atomic operation)
            await expenseHiveRepository.replaceExpenseId(localId, apiExpense.id);

            // Update state with server ID
            final updatedExpenses = state.expenses.map((e) {
              return e.id == localId ? updatedExpense : e;
            }).toList();
            state = state.copyWith(
              expenses: updatedExpenses,
              syncStatus: ExpenseSyncStatus.success,
              isQueued: false,
              lastSyncError: null,
            );

            // Update per-expense status
            _updateExpenseSyncStatus(apiExpense.id, ExpenseSyncStatus.success);

            AppLogger.info('✅ Synced expense create: ${expense.name} -> ${apiExpense.id}');
          } else if (operation == SyncOperation.update) {
            // Get backend category ID
            final backendCategoryId = await _getBackendCategoryId(expense.category);

            // Update expense on server
            await expenseApi.updateExpense(
              expenseId: expense.id,
              name: expense.name,
              amount: expense.amount,
              date: expense.date,
              categoryId: backendCategoryId,
              description: expense.description,
            );

            state = state.copyWith(
              syncStatus: ExpenseSyncStatus.success,
              isQueued: false,
              lastSyncError: null,
            );

            // Update per-expense status
            _updateExpenseSyncStatus(expense.id, ExpenseSyncStatus.success);

            AppLogger.info('✅ Synced expense update: ${expense.name}');
          }

          // Update last sync time
          ref.read(appStateProvider.notifier).updateLastSyncTime(DateTime.now());
        } catch (e) {
          // Check if this is a validation error (400 status)
          final isValidationError = _isValidationError(e);
          final errorMessage = _getUserFriendlyError(e);
          
          if (isValidationError) {
            // Validation error - remove from local state and Hive
            AppLogger.warning('❌ Validation error, removing expense from local', e);
            final updatedExpenses = state.expenses
                .where((exp) => exp.id != expense.id)
                .toList();
            await expenseHiveRepository.deleteExpense(expense.id);
            state = state.copyWith(
              expenses: updatedExpenses,
              syncStatus: ExpenseSyncStatus.failed,
              isQueued: false,
              lastSyncError: 'Invalid expense data: $errorMessage',
            );
            // Update per-expense status
            _updateExpenseSyncStatus(expense.id, ExpenseSyncStatus.failed);
          } else {
            // Network/server error - queue for later
            AppLogger.warning('⚠️ Online sync failed, queueing for later', e);
            await _queueExpenseSync(expense, operation);
            state = state.copyWith(
              syncStatus: ExpenseSyncStatus.failed,
              isQueued: true,
              lastSyncError: errorMessage,
            );
            // Update per-expense status
            _updateExpenseSyncStatus(expense.id, ExpenseSyncStatus.queued);
          }
        }
      } else {
        // Queue for later sync
        await _queueExpenseSync(expense, operation);
        state = state.copyWith(
          syncStatus: ExpenseSyncStatus.queued,
          isQueued: true,
          lastSyncError: isOnline
              ? 'Not authenticated'
              : 'No internet connection',
        );
        // Update per-expense status
        _updateExpenseSyncStatus(expense.id, ExpenseSyncStatus.queued);
      }
    } catch (e) {
      // Don't fail the operation if sync fails
      final errorMessage = _getUserFriendlyError(e);
      ErrorHandler.logError('Failed to sync expense', e);
      state = state.copyWith(
        syncStatus: ExpenseSyncStatus.failed,
        lastSyncError: errorMessage,
      );
    }
  }

  /// Check if error is a validation error (400 status)
  bool _isValidationError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      // 400 Bad Request or 422 Unprocessable Entity are validation errors
      return statusCode == 400 || statusCode == 422;
    }
    final errorString = error.toString().toLowerCase();
    return errorString.contains('400') || errorString.contains('bad request') ||
           errorString.contains('validation') || errorString.contains('invalid');
  }

  /// Get user-friendly error message
  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return 'No internet connection';
    }
    if (errorString.contains('timeout')) {
      return 'Request timed out';
    }
    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Please sign in to sync';
    }
    if (errorString.contains('400') || errorString.contains('bad request')) {
      return 'Invalid expense data';
    }
    if (errorString.contains('500') || errorString.contains('server')) {
      return 'Server error, please try again';
    }
    return 'Sync failed. Please try again';
  }

  /// Queue expense for later sync
  Future<void> _queueExpenseSync(
    Expense expense,
    SyncOperation operation,
  ) async {
    final syncQueue = locator<SyncQueueService>();
    final localId = operation == SyncOperation.create ? expense.id : null;

    // Get backend category ID for queue
    final backendCategoryId = await _getBackendCategoryId(expense.category);

    await syncQueue.enqueue(
      entityType: 'expense',
      operation: operation,
      data: {
        'id': expense.id,
        'name': expense.name,
        'amount': expense.amount,
        'date': expense.date.toIso8601String(),
        'categoryId': backendCategoryId,
        'description': expense.description,
      },
      localId: localId,
    );

    // Update pending sync count
    final pendingCount = syncQueue.getPendingItems().length;
    ref.read(appStateProvider.notifier).updatePendingSyncCount(pendingCount);
  }

  /// Handle sync for expense deletion
  Future<void> _handleSyncForDelete(String expenseId) async {
    try {
      final appState = ref.read(appStateProvider);
      final networkService = locator<NetworkService>();
      final isOnline = await networkService.isConnected;

      // Set syncing status
      state = state.copyWith(syncStatus: ExpenseSyncStatus.syncing);

      if (appState.canSync && isOnline) {
        // Try to sync immediately if authenticated and online
        try {
          final expenseApi = expenseApiRepository;
          await expenseApi.deleteExpense(expenseId);

          state = state.copyWith(
            syncStatus: ExpenseSyncStatus.success,
            isQueued: false,
            lastSyncError: null,
          );

          AppLogger.info('✅ Synced expense deletion: $expenseId');

          // Update last sync time
          ref.read(appStateProvider.notifier).updateLastSyncTime(DateTime.now());
        } catch (e) {
          // Check if this is a validation error (400 status)
          final isValidationError = _isValidationError(e);
          final errorMessage = _getUserFriendlyError(e);
          
          if (isValidationError) {
            // Validation error - item already deleted or doesn't exist on server
            AppLogger.warning('⚠️ Delete validation error (item may not exist on server)', e);
            // Don't re-add locally, just mark as successful since it's already gone
            state = state.copyWith(
              syncStatus: ExpenseSyncStatus.success,
              isQueued: false,
              lastSyncError: null,
            );
          } else {
            // Network/server error - queue for later
            AppLogger.warning('⚠️ Online sync failed, queueing for later', e);
            await _queueDeleteSync(expenseId);
            state = state.copyWith(
              syncStatus: ExpenseSyncStatus.failed,
              isQueued: true,
              lastSyncError: errorMessage,
            );
          }
        }
      } else {
        // Queue for later sync
        await _queueDeleteSync(expenseId);
        state = state.copyWith(
          syncStatus: ExpenseSyncStatus.queued,
          isQueued: true,
          lastSyncError: isOnline
              ? 'Not authenticated'
              : 'No internet connection',
        );
      }
    } catch (e) {
      // Don't fail the operation if sync fails
      final errorMessage = _getUserFriendlyError(e);
      ErrorHandler.logError('Failed to sync expense deletion', e);
      state = state.copyWith(
        syncStatus: ExpenseSyncStatus.failed,
        lastSyncError: errorMessage,
      );
    }
  }

  /// Queue delete for later sync
  Future<void> _queueDeleteSync(String expenseId) async {
    final syncQueue = locator<SyncQueueService>();
    await syncQueue.enqueue(
      entityType: 'expense',
      operation: SyncOperation.delete,
      data: {'id': expenseId},
    );

    // Update pending sync count
    final pendingCount = syncQueue.getPendingItems().length;
    ref.read(appStateProvider.notifier).updatePendingSyncCount(pendingCount);
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, ExpensesState>(() {
  return ExpensesNotifier();
});
