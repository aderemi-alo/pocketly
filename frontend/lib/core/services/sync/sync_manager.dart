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
import 'package:dio/dio.dart';

/// Callback interface for updating app state from sync manager
typedef AppStateUpdater =
    void Function({DateTime? lastSyncTime, int? pendingSyncCount});

/// Callback for checking if sync is allowed
typedef CanSyncChecker = bool Function();

class SyncManager {
  final SyncQueueService _syncQueue;
  final NetworkService _networkService;
  final ExpenseApiRepository _expenseApi;
  final CategoryApiRepository _categoryApi;
  final ExpenseCacheManager _cacheManager;
  final ConflictResolution? _conflictResolver;
  final AppStateUpdater? _appStateUpdater;
  final CanSyncChecker? _canSyncChecker;

  bool _isSyncing = false;
  Timer? _periodicSyncTimer;
  StreamSubscription? _connectivitySubscription;

  SyncManager({
    required SyncQueueService syncQueue,
    required NetworkService networkService,
    required ExpenseApiRepository expenseApi,
    required CategoryApiRepository categoryApi,
    required ExpenseCacheManager cacheManager,
    ConflictResolution? conflictResolver,
    AppStateUpdater? appStateUpdater,
    CanSyncChecker? canSyncChecker,
  }) : _syncQueue = syncQueue,
       _networkService = networkService,
       _expenseApi = expenseApi,
       _categoryApi = categoryApi,
       _cacheManager = cacheManager,
       _conflictResolver = conflictResolver,
       _appStateUpdater = appStateUpdater,
       _canSyncChecker = canSyncChecker;

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
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncPendingOperations(),
    );
  }

  /// Sync all pending operations
  Future<void> syncPendingOperations() async {
    if (_isSyncing) {
      debugPrint('⏳ Sync already in progress');
      return;
    }

    // Check app state first - only sync if can sync
    if (_canSyncChecker != null && !_canSyncChecker()) {
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
        await _syncItem(item);
      }

      // Update app state after successful sync
      _appStateUpdater?.call(lastSyncTime: DateTime.now());
      final pendingCount = _syncQueue.getPendingItems().length;
      _appStateUpdater?.call(pendingSyncCount: pendingCount);

      debugPrint('✅ Sync completed successfully');
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
      // Don't throw - just log the error
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync individual item
  Future<void> _syncItem(SyncQueueItem item) async {
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
    } catch (e) {
      // Check if error is retryable
      if (_isRetryableError(e)) {
        await _syncQueue.markFailed(item.id, e.toString());
        debugPrint('❌ Failed to sync ${item.entityType}: $e (will retry)');

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
      }
    }
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
