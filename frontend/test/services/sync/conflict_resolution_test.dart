import 'package:flutter_test/flutter_test.dart';
import 'package:pocketly/core/services/sync/conflict_resolution_service.dart';

void main() {
  group('ConflictResolution', () {
    late ConflictResolution resolver;

    setUp(() {
      resolver = ConflictResolution(
        strategy: ConflictResolutionStrategy.newerWins,
      );
    });

    test('Newer Wins: Local is newer -> Returns local data', () {
      final localData = {'name': 'Local', 'amount': 100};
      final serverData = {'name': 'Server', 'amount': 50};
      final localTime = DateTime.parse('2023-01-01T12:00:00Z');
      final serverTime = DateTime.parse('2023-01-01T10:00:00Z');

      final result = resolver.resolve(
        localData: localData,
        serverData: serverData,
        localUpdatedAt: localTime,
        serverUpdatedAt: serverTime,
      );

      expect(result, equals(localData));
    });

    test('Newer Wins: Server is newer -> Returns server data', () {
      final localData = {'name': 'Local', 'amount': 100};
      final serverData = {'name': 'Server', 'amount': 50};
      final localTime = DateTime.parse('2023-01-01T10:00:00Z');
      final serverTime = DateTime.parse('2023-01-01T12:00:00Z');

      final result = resolver.resolve(
        localData: localData,
        serverData: serverData,
        localUpdatedAt: localTime,
        serverUpdatedAt: serverTime,
      );

      expect(result, equals(serverData));
    });

    test(
      'Newer Wins: Timestamps identical -> Returns local data (Client Wins)',
      () {
        final localData = {'name': 'Local', 'amount': 100};
        final serverData = {'name': 'Server', 'amount': 50};
        final time = DateTime.parse('2023-01-01T12:00:00Z');

        final result = resolver.resolve(
          localData: localData,
          serverData: serverData,
          localUpdatedAt: time,
          serverUpdatedAt: time,
        );

        expect(result, equals(localData));
      },
    );

    test('Server Wins Strategy: Always returns server data', () {
      resolver = ConflictResolution(
        strategy: ConflictResolutionStrategy.serverWins,
      );

      final localData = {'name': 'Local', 'amount': 100};
      final serverData = {'name': 'Server', 'amount': 50};
      // Even if local is newer
      final localTime = DateTime.parse('2023-01-01T12:00:00Z');
      final serverTime = DateTime.parse('2023-01-01T10:00:00Z');

      final result = resolver.resolve(
        localData: localData,
        serverData: serverData,
        localUpdatedAt: localTime,
        serverUpdatedAt: serverTime,
      );

      expect(result, equals(serverData));
    });

    test('Client Wins Strategy: Always returns local data', () {
      resolver = ConflictResolution(
        strategy: ConflictResolutionStrategy.clientWins,
      );

      final localData = {'name': 'Local', 'amount': 100};
      final serverData = {'name': 'Server', 'amount': 50};
      // Even if server is newer
      final localTime = DateTime.parse('2023-01-01T10:00:00Z');
      final serverTime = DateTime.parse('2023-01-01T12:00:00Z');

      final result = resolver.resolve(
        localData: localData,
        serverData: serverData,
        localUpdatedAt: localTime,
        serverUpdatedAt: serverTime,
      );

      expect(result, equals(localData));
    });
  });
}
