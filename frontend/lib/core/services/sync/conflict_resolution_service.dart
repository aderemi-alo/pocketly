import 'package:pocketly/core/services/logger_service.dart';

enum ConflictResolutionStrategy { serverWins, clientWins, newerWins, manual }

class ConflictResolution {
  final ConflictResolutionStrategy strategy;

  ConflictResolution({this.strategy = ConflictResolutionStrategy.newerWins});

  /// Resolve conflict between local and server data
  Map<String, dynamic> resolve({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> serverData,
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
  }) {
    switch (strategy) {
      case ConflictResolutionStrategy.serverWins:
        AppLogger.debug('🔀 Conflict resolved: Server wins');
        return serverData;

      case ConflictResolutionStrategy.clientWins:
        AppLogger.debug('🔀 Conflict resolved: Client wins');
        return localData;

      case ConflictResolutionStrategy.newerWins:
        if (localUpdatedAt.isAfter(serverUpdatedAt)) {
          AppLogger.debug('🔀 Conflict resolved: Local is newer');
          return localData;
        } else {
          AppLogger.debug('🔀 Conflict resolved: Server is newer');
          return serverData;
        }

      case ConflictResolutionStrategy.manual:
        throw ConflictException(
          localData: localData,
          serverData: serverData,
          message: 'Manual conflict resolution required',
          entityName: 'item',
        );
    }
  }

  /// Check if data has conflicts
  bool hasConflict({
    required Map<String, dynamic> localData,
    required Map<String, dynamic> serverData,
  }) {
    // Compare critical fields (exclude timestamps)
    final localCopy = Map<String, dynamic>.from(localData)
      ..remove('updatedAt')
      ..remove('createdAt');
    final serverCopy = Map<String, dynamic>.from(serverData)
      ..remove('updatedAt')
      ..remove('createdAt');

    return localCopy.toString() != serverCopy.toString();
  }
}

class ConflictException implements Exception {
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final String message;
  final String? entityName;

  ConflictException({
    required this.localData,
    required this.serverData,
    required this.message,
    this.entityName,
  });

  @override
  String toString() => message;
}
