import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:pocketly/core/services/sync/sync_models.dart';
import 'package:uuid/uuid.dart';

class SyncQueueService {
  static const String _boxName = 'sync_queue';
  static const int maxRetries = 3;

  Box<SyncQueueItem> get _box => Hive.box<SyncQueueItem>(_boxName);
  final _uuid = const Uuid();

  Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<SyncQueueItem>(_boxName);
    }
  }

  /// Add operation to sync queue
  Future<String> enqueue({
    required String entityType,
    required SyncOperation operation,
    required Map<String, dynamic> data,
    String? localId,
    String? serverId,
  }) async {
    final id = _uuid.v4();
    final item = SyncQueueItem(
      id: id,
      entityType: entityType,
      operation: operation.name,
      data: data,
      timestamp: DateTime.now(),
      localId: localId,
      serverId: serverId,
    );

    await _box.put(id, item);
    debugPrint('📝 Enqueued ${operation.name} for $entityType (ID: $id)');
    return id;
  }

  /// Get all pending items
  List<SyncQueueItem> getPendingItems() {
    return _box.values.where((item) => item.status == 'pending').toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get failed items
  List<SyncQueueItem> getFailedItems() {
    return _box.values
        .where(
          (item) => item.status == 'failed' && item.retryCount < maxRetries,
        )
        .toList();
  }

  /// Mark item as in progress
  Future<void> markInProgress(String id) async {
    final item = _box.get(id);
    if (item != null) {
      await _box.put(id, item.copyWith(status: 'inProgress'));
    }
  }

  /// Mark item as completed
  Future<void> markCompleted(String id, {String? serverId}) async {
    final item = _box.get(id);
    if (item != null) {
      await _box.put(
        id,
        item.copyWith(status: 'completed', serverId: serverId),
      );

      // Delete completed items after 24 hours
      Future.delayed(const Duration(hours: 24), () {
        _box.delete(id);
      });
    }
  }

  /// Mark item as failed
  Future<void> markFailed(String id, String error) async {
    final item = _box.get(id);
    if (item != null) {
      await _box.put(
        id,
        item.copyWith(
          status: 'failed',
          retryCount: item.retryCount + 1,
          error: error,
        ),
      );
    }
  }

  /// Remove item from queue
  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  /// Get queue size
  int get queueSize => _box.length;

  /// Clear all completed items
  Future<void> clearCompleted() async {
    final completedKeys = _box.values
        .where((item) => item.status == 'completed')
        .map((item) => item.id)
        .toList();

    await _box.deleteAll(completedKeys);
  }

  /// Clear entire queue (use with caution)
  Future<void> clearAll() async {
    await _box.clear();
  }
}
