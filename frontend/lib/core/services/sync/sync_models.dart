import 'package:hive/hive.dart';

part 'sync_models.g.dart';

enum SyncOperation { create, update, delete }

enum SyncStatus { pending, inProgress, failed, completed }

@HiveType(typeId: 10)
class SyncQueueItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String entityType;

  @HiveField(2)
  final String operation;

  @HiveField(3)
  final Map<String, dynamic> data;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final int retryCount;

  @HiveField(7)
  final String? error;

  @HiveField(8)
  final String? localId;

  @HiveField(9)
  final String? serverId;

  SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.status = 'pending',
    this.retryCount = 0,
    this.error,
    this.localId,
    this.serverId,
  });

  SyncQueueItem copyWith({
    String? status,
    int? retryCount,
    String? error,
    String? serverId,
  }) {
    return SyncQueueItem(
      id: id,
      entityType: entityType,
      operation: operation,
      data: data,
      timestamp: timestamp,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      error: error,
      localId: localId,
      serverId: serverId ?? this.serverId,
    );
  }
}
