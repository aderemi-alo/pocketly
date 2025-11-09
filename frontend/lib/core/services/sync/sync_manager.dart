import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pocketly/core/services/network_service.dart';
import 'package:pocketly/core/services/sync/conflict_resolution_service.dart';
import 'package:pocketly/core/services/sync/sync_models.dart';
import 'package:pocketly/core/services/sync/sync_queue_service.dart';
import 'package:pocketly/core/utils/icon_mapper.dart';
import 'package:pocketly/features/expenses/data/cache/expense_cache_manager.dart';
import 'package:pocketly/features/expenses/data/models/expense_hive.dart';
import 'package:pocketly/features/expenses/data/repositories/category_api_repository.dart';
import 'package:pocketly/features/expenses/data/repositories/expense_api_repository.dart';
import 'package:pocketly/features/expenses/data/models/expense_api_model.dart';
import 'package:pocketly/features/expenses/domain/repo/expense_hive_repository.dart';
import 'package:pocketly/features/expenses/domain/models/expense.dart';
import 'package:pocketly/features/expenses/domain/models/category.dart';
import 'package:dio/dio.dart';

/// Callback interface for updating app state from sync manager
typedef AppStateUpdater =
    void Function({
      DateTime? lastSyncTime,
      int? pendingSyncCount,
      int? failedSyncCount,
      bool? isSyncing,
      String? lastSyncError,
    });

/// Callback for checking if sync is allowed
typedef CanSyncChecker = bool Function();

/// Callback for sync events
typedef OnSyncStart = void Function();
typedef OnSyncComplete = void Function({int successCount, int failureCount});
typedef OnSyncItemFailed =
    void Function(String entityType, String operation, String error);

class SyncManager {
  final SyncQueueService _syncQueue;
  final NetworkService _networkService;
  final ExpenseApiRepository _expenseApi;
  final CategoryApiRepository _categoryApi;
  final ExpenseCacheManager _cacheManager;
  final ExpenseHiveRepository _expenseHiveRepository;
  final ConflictResolution? _conflictResolver;
  AppStateUpdater? _appStateUpdater;
  CanSyncChecker? _canSyncChecker;
  OnSyncStart? _onSyncStart;
  OnSyncComplete? _onSyncComplete;
  OnSyncItemFailed? _onSyncItemFailed;

  bool _isSyncing = false;
  Timer? _periodicSyncTimer;
  StreamSubscription? _connectivitySubscription;

  SyncManager({
    required SyncQueueService syncQueue,
    required NetworkService networkService,
    required ExpenseApiRepository expenseApi,
    required CategoryApiRepository categoryApi,
    required ExpenseCacheManager cacheManager,
    required ExpenseHiveRepository expenseHiveRepository,
    ConflictResolution? conflictResolver,
    AppStateUpdater? appStateUpdater,
    CanSyncChecker? canSyncChecker,
    OnSyncStart? onSyncStart,
    OnSyncComplete? onSyncComplete,
    OnSyncItemFailed? onSyncItemFailed,
  }) : _syncQueue = syncQueue,
       _networkService = networkService,
       _expenseApi = expenseApi,
       _categoryApi = categoryApi,
       _cacheManager = cacheManager,
       _expenseHiveRepository = expenseHiveRepository,
       _conflictResolver = conflictResolver,
       _appStateUpdater = appStateUpdater,
       _canSyncChecker = canSyncChecker,
       _onSyncStart = onSyncStart,
       _onSyncComplete = onSyncComplete,
       _onSyncItemFailed = onSyncItemFailed;

  /// Setup callbacks for sync manager
  void setupCallbacks({
    AppStateUpdater? appStateUpdater,
    CanSyncChecker? canSyncChecker,
    OnSyncStart? onSyncStart,
    OnSyncComplete? onSyncComplete,
    OnSyncItemFailed? onSyncItemFailed,
  }) {
    _appStateUpdater = appStateUpdater ?? _appStateUpdater;
    _canSyncChecker = canSyncChecker ?? _canSyncChecker;
    _onSyncStart = onSyncStart ?? _onSyncStart;
    _onSyncComplete = onSyncComplete ?? _onSyncComplete;
    _onSyncItemFailed = onSyncItemFailed ?? _onSyncItemFailed;
  }

  /// Initialize sync manager
  Future<void> initialize() async {
    await _syncQueue.initialize();
    await _cacheManager.initialize();

    // Listen to connectivity changes
    _connectivitySubscription = _networkService.connectivityStream.listen((
      isConnected,
    ) {
      if (isConnected && !_isSyncing) {
        debugPrint('📡 Network restored, starting sync...');
        syncPendingOperations();
      }
    });

    // Start periodic sync (every 5 minutes when online)
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      // Check connectivity before running periodic sync
      final isOnline = await _networkService.isConnected;
      if (isOnline && (_canSyncChecker == null || _canSyncChecker!())) {
        syncPendingOperations();
      }
    });
  }

  /// Sync all pending operations
  Future<void> syncPendingOperations() async {
    if (_isSyncing) {
      debugPrint('⏳ Sync already in progress');
      return;
    }

    // Check app state first - only sync if can sync
    if (_canSyncChecker != null && !_canSyncChecker!()) {
      debugPrint('📴 Cannot sync - not authenticated');
      return;
    }

    final isOnline = await _networkService.isConnected;
    if (!isOnline) {
      debugPrint('📴 Offline, skipping sync');
      return;
    }

    _isSyncing = true;
    debugPrint('🔄 Starting sync...');
    _appStateUpdater?.call(isSyncing: true);
    _onSyncStart?.call();

    int successCount = 0;
    int failureCount = 0;

    try {
      final pendingItems = _syncQueue.getPendingItems();
      final failedItems = _syncQueue.getFailedItems();
      final allItems = [...pendingItems, ...failedItems];

      debugPrint('📊 Sync queue: ${allItems.length} items');

      for (final item in allItems) {
        // Apply exponential backoff for failed items
        if (item.status == 'failed' && item.retryCount > 0) {
          final delaySeconds = pow(2, item.retryCount).clamp(1, 60).toInt();
          debugPrint(
            '⏱️ Waiting ${delaySeconds}s before retry (attempt ${item.retryCount})',
          );
          await Future.delayed(Duration(seconds: delaySeconds));
        }

        final result = await _syncItem(item);
        if (result) {
          successCount++;
        } else {
          failureCount++;
        }
      }

      // Update app state after sync
      final pendingCount = _syncQueue.getPendingItems().length;
      final failedCount = _syncQueue.getFailedItems().length;
      _appStateUpdater?.call(
        lastSyncTime: DateTime.now(),
        pendingSyncCount: pendingCount,
        failedSyncCount: failedCount,
        isSyncing: false,
      );

      _onSyncComplete?.call(
        successCount: successCount,
        failureCount: failureCount,
      );

      debugPrint(
        '✅ Sync completed: $successCount succeeded, $failureCount failed',
      );

      // After pushing local changes, pull server changes
      await pullExpensesFromServer();
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
      _onSyncComplete?.call(
        successCount: successCount,
        failureCount: failureCount + 1,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Pull expenses from server and merge with local
  Future<void> pullExpensesFromServer() async {
    if (!await _networkService.isConnected) {
      debugPrint('📴 Offline, skipping pull sync');
      return;
    }

    if (_canSyncChecker != null && !_canSyncChecker!()) {
      debugPrint('📴 Cannot pull - not authenticated');
      return;
    }

    try {
      debugPrint('📥 Pulling expenses from server...');

      // Fetch all expenses from server (handle pagination)
      final List<ExpenseApiModel> serverExpenses = [];
      int offset = 0;
      const limit = 50;
      bool hasMore = true;

      while (hasMore) {
        final response = await _expenseApi.getExpenses(
          limit: limit,
          offset: offset,
          includeCategory: true,
        );

        final expenses = response['expenses'] as List<ExpenseApiModel>;
        serverExpenses.addAll(expenses);
        hasMore = response['hasMore'] as bool;
        offset += limit;
      }

      debugPrint('📥 Fetched ${serverExpenses.length} expenses from server');

      // Get local expenses
      final localExpenses = await _expenseHiveRepository.getAllExpenses();

      // Merge expenses
      await _mergeExpenses(serverExpenses, localExpenses);

      debugPrint('✅ Pull sync completed');
    } catch (e) {
      debugPrint('❌ Pull sync failed: $e');
      // Don't throw - just log the error
    }
  }

  /// Merge server expenses with local expenses
  Future<void> _mergeExpenses(
    List<ExpenseApiModel> serverExpenses,
    List<Expense> localExpenses,
  ) async {
    final localExpenseMap = {
      for (final expense in localExpenses) expense.id: expense,
    };

    final expensesToAdd = <Expense>[];
    final expensesToUpdate = <Expense>[];

    // Process server expenses
    for (final serverExpense in serverExpenses) {
      final localExpense = localExpenseMap[serverExpense.id];

      if (localExpense == null) {
        // New expense from server - add it
        final expense = _convertApiModelToExpense(serverExpense);
        if (expense != null) {
          expensesToAdd.add(expense);
        }
      } else {
        // Expense exists in both - resolve conflict and update
        final expense = _resolveConflict(localExpense, serverExpense);
        expensesToUpdate.add(expense);
      }
    }

    // Add new expenses from server
    for (final expense in expensesToAdd) {
      await _expenseHiveRepository.addExpense(expense);
    }

    // Update existing expenses
    for (final expense in expensesToUpdate) {
      await _expenseHiveRepository.updateExpense(expense);
    }

    // Note: Local expenses that don't exist on server are already in the database
    // and will be pushed to server later via sync queue

    debugPrint(
      '✅ Merged expenses: ${expensesToAdd.length} added, ${expensesToUpdate.length} updated',
    );
  }

  /// Convert ExpenseApiModel to Expense domain model
  Expense? _convertApiModelToExpense(ExpenseApiModel apiExpense) {
    try {
      Category category;
      if (apiExpense.category != null) {
        category = apiExpense.category!.toDomain();
      } else {
        // Use default category if category is null
        category = Category(
          id: apiExpense.categoryId,
          name: 'Uncategorized',
          icon: Icons.category,
          color: Colors.grey,
        );
      }

      return Expense(
        id: apiExpense.id,
        name: apiExpense.name,
        amount: apiExpense.amount,
        date: apiExpense.date,
        description: apiExpense.description,
        category: category,
      );
    } catch (e) {
      debugPrint('Failed to convert ExpenseApiModel to Expense: $e');
      return null;
    }
  }

  /// Resolve conflict between local and server expense
  Expense _resolveConflict(
    Expense localExpense,
    ExpenseApiModel serverExpense,
  ) {
    if (_conflictResolver != null) {
      // Use conflict resolver if available
      final localData = {
        'name': localExpense.name,
        'amount': localExpense.amount,
        'date': localExpense.date.toIso8601String(),
        'description': localExpense.description,
      };
      final serverData = {
        'name': serverExpense.name,
        'amount': serverExpense.amount,
        'date': serverExpense.date.toIso8601String(),
        'description': serverExpense.description,
      };

      final resolved = _conflictResolver.resolve(
        localData: localData,
        serverData: serverData,
        localUpdatedAt: DateTime.now(), // We don't track this in Expense model
        serverUpdatedAt: serverExpense.updatedAt,
      );

      // Use server expense as base and apply resolved data
      final expense = _convertApiModelToExpense(serverExpense);
      if (expense != null) {
        return expense.copyWith(
          name: resolved['name'] as String,
          amount: (resolved['amount'] as num).toDouble(),
          date: DateTime.parse(resolved['date'] as String),
          description: resolved['description'] as String?,
        );
      }
    }

    // Default: server wins if newer (or always server wins if no timestamp)
    return _convertApiModelToExpense(serverExpense) ?? localExpense;
  }

  /// Sync individual item
  /// Returns true if successful, false if failed
  Future<bool> _syncItem(SyncQueueItem item) async {
    try {
      await _syncQueue.markInProgress(item.id);

      switch (item.entityType) {
        case 'expense':
          await _syncExpense(item);
          break;
        case 'category':
          await _syncCategory(item);
          break;
        default:
          throw Exception('Unknown entity type: ${item.entityType}');
      }

      await _syncQueue.markCompleted(item.id);
      debugPrint('✅ Synced ${item.entityType} ${item.operation}');
      return true;
    } catch (e) {
      final errorMessage = _getUserFriendlyError(e);

      // Check if error is retryable
      if (_isRetryableError(e)) {
        await _syncQueue.markFailed(item.id, errorMessage);
        debugPrint('❌ Failed to sync ${item.entityType}: $e (will retry)');
        _onSyncItemFailed?.call(item.entityType, item.operation, errorMessage);

        // Remove from queue if max retries exceeded
        if (item.retryCount >= SyncQueueService.maxRetries) {
          await _syncQueue.remove(item.id);
          debugPrint('🗑️ Removed item from queue (max retries exceeded)');
        }
      } else {
        // Non-retryable error (client error), remove immediately
        await _syncQueue.remove(item.id);
        debugPrint(
          '❌ Failed to sync ${item.entityType}: $e (non-retryable, removed)',
        );
        _onSyncItemFailed?.call(item.entityType, item.operation, errorMessage);
      }
      return false;
    }
  }

  /// Get user-friendly error message
  String _getUserFriendlyError(dynamic error) {
    // Network errors
    if (error is SocketException) {
      return 'No internet connection';
    }
    if (error is TimeoutException) {
      return 'Request timed out';
    }

    // Dio errors
    if (error is DioException) {
      final statusCode = error.response?.statusCode;

      if (statusCode != null) {
        if (statusCode == 401) {
          return 'Please sign in to sync';
        }
        if (statusCode >= 400 && statusCode < 500) {
          return 'Invalid request. Please check your data';
        }
        if (statusCode >= 500) {
          return 'Server error, please try again';
        }
      }

      // Network-related Dio errors
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Request timed out';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection';
      }
    }

    // Conflict exceptions
    if (error is ConflictException) {
      return 'Conflict detected. Please resolve manually';
    }

    // Default
    return 'Sync failed. Please try again';
  }

  /// Check if error is retryable
  bool _isRetryableError(dynamic error) {
    // Network errors - retryable
    if (error is SocketException || error is TimeoutException) {
      return true;
    }

    // Dio errors
    if (error is DioException) {
      final statusCode = error.response?.statusCode;

      // Server errors (5xx) - retryable
      if (statusCode != null && statusCode >= 500) {
        return true;
      }

      // Client errors (4xx) - not retryable (except 401 which is handled by token refresh)
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        // 401 is handled by token refresh in ApiClient, so we can retry
        if (statusCode == 401) {
          return true;
        }
        return false;
      }

      // Network-related Dio errors - retryable
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return true;
      }
    }

    // Conflict exceptions - not retryable (needs manual resolution)
    if (error is ConflictException) {
      return false;
    }

    // Default: retryable for unknown errors
    return true;
  }

  /// Sync expense operation
  Future<void> _syncExpense(SyncQueueItem item) async {
    switch (item.operation) {
      case 'create':
        final expense = await _expenseApi
            .createExpense(
              name: item.data['name'],
              amount: (item.data['amount'] as num).toDouble(),
              date: DateTime.parse(item.data['date']),
              categoryId: item.data['categoryId'],
              description: item.data['description'],
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () =>
                  throw TimeoutException('Expense creation timed out'),
            );

        // Update local ID mapping
        if (item.localId != null) {
          await _updateLocalIdMapping(item.localId!, expense.id);
        }

        // Cache the created expense
        if (expense.category != null) {
          final cachedExpense = ExpenseHive.create(
            expenseId: expense.id,
            name: expense.name,
            amount: expense.amount,
            date: expense.date,
            categoryId: expense.categoryId,
            categoryName: expense.category!.name,
            categoryIcon: IconMapper.getIconFromString(expense.category!.icon),
            categoryColor: Color(
              int.parse(expense.category!.color.replaceFirst('#', '0xFF')),
            ),
            description: expense.description,
          );
          await _cacheManager.cacheExpense(cachedExpense);
        }
        break;

      case 'update':
        final expense = await _expenseApi
            .updateExpense(
              expenseId: item.data['id'],
              name: item.data['name'],
              amount: item.data['amount'] != null
                  ? (item.data['amount'] as num).toDouble()
                  : null,
              date: item.data['date'] != null
                  ? DateTime.parse(item.data['date'])
                  : null,
              categoryId: item.data['categoryId'],
              description: item.data['description'],
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () =>
                  throw TimeoutException('Expense update timed out'),
            );

        // Update cache
        if (expense.category != null) {
          final cachedExpense = ExpenseHive.create(
            expenseId: expense.id,
            name: expense.name,
            amount: expense.amount,
            date: expense.date,
            categoryId: expense.categoryId,
            categoryName: expense.category!.name,
            categoryIcon: IconMapper.getIconFromString(expense.category!.icon),
            categoryColor: Color(
              int.parse(expense.category!.color.replaceFirst('#', '0xFF')),
            ),
            description: expense.description,
          );
          await _cacheManager.updateCachedExpense(cachedExpense);
        }
        break;

      case 'delete':
        await _expenseApi
            .deleteExpense(item.data['id'])
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () =>
                  throw TimeoutException('Expense deletion timed out'),
            );
        await _cacheManager.removeCachedExpense(item.data['id']);
        break;
    }
  }

  /// Sync category operation
  Future<void> _syncCategory(SyncQueueItem item) async {
    switch (item.operation) {
      case 'create':
        await _categoryApi.createCategory(
          name: item.data['name'],
          icon: item.data['icon'],
          color: item.data['color'],
        );
        break;

      case 'update':
        await _categoryApi.updateCategory(
          categoryId: item.data['id'],
          name: item.data['name'],
          icon: item.data['icon'],
          color: item.data['color'],
        );
        break;

      case 'delete':
        await _categoryApi.deleteCategory(item.data['id']);
        break;
    }
  }

  /// Update local ID to server ID mapping
  Future<void> _updateLocalIdMapping(String localId, String serverId) async {
    // Update cache with server ID
    final cachedExpense = _cacheManager.getCachedExpense(localId);
    if (cachedExpense != null) {
      final updated = ExpenseHive.create(
        expenseId: serverId,
        name: cachedExpense.name,
        amount: cachedExpense.amount,
        date: cachedExpense.date,
        categoryId: cachedExpense.categoryId,
        categoryName: cachedExpense.categoryName,
        categoryIcon: IconMapper.getIcon(cachedExpense.categoryIconCodePoint),
        categoryColor: Color(cachedExpense.categoryColorValue),
        description: cachedExpense.description,
      );
      await _cacheManager.removeCachedExpense(localId);
      await _cacheManager.cacheExpense(updated);
    }
  }

  /// Force sync now
  Future<void> forceSyncNow() async {
    await syncPendingOperations();
  }

  /// Pause sync (stop timers and listeners)
  void pauseSync() {
    _periodicSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
    debugPrint('⏸️ Sync paused');
  }

  /// Resume sync (restart timers and listeners)
  Future<void> resumeSync() async {
    // Cancel existing timers first
    _periodicSyncTimer?.cancel();
    _connectivitySubscription?.cancel();

    // Listen to connectivity changes
    _connectivitySubscription = _networkService.connectivityStream.listen((
      isConnected,
    ) {
      if (isConnected && !_isSyncing) {
        debugPrint('📡 Network restored, starting sync...');
        syncPendingOperations();
      }
    });

    // Start periodic sync (every 5 minutes when online)
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      // Check connectivity before running periodic sync
      final isOnline = await _networkService.isConnected;
      if (isOnline && (_canSyncChecker == null || _canSyncChecker!())) {
        syncPendingOperations();
      }
    });

    debugPrint('▶️ Sync resumed');
  }

  /// Get sync status
  bool get isSyncing => _isSyncing;

  int get pendingCount => _syncQueue.getPendingItems().length;

  int get failedCount => _syncQueue.getFailedItems().length;

  /// Dispose resources
  void dispose() {
    _periodicSyncTimer?.cancel();
    _connectivitySubscription?.cancel();
  }
}
