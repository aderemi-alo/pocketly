import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:test/test.dart';

import '../../../routes/expenses/sync.dart' as route;

class MockExpenseRepository extends Mock implements ExpenseRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockRequestContext extends Mock implements RequestContext {}

class MockRequest extends Mock implements Request {}

void main() {
  group('POST /expenses/sync', () {
    late MockExpenseRepository expenseRepo;
    late MockCategoryRepository categoryRepo;
    late MockRequestContext context;
    late MockRequest request;

    setUp(() {
      expenseRepo = MockExpenseRepository();
      categoryRepo = MockCategoryRepository();
      context = MockRequestContext();
      request = MockRequest();

      when(() => context.read<ExpenseRepository>()).thenReturn(expenseRepo);
      when(() => context.read<CategoryRepository>()).thenReturn(categoryRepo);
      when(() => context.request).thenReturn(request);
      when(() => request.method).thenReturn(HttpMethod.post);

      // Mock user ID payload
      when(() => context.read<Map<dynamic, dynamic>>())
          .thenReturn({'uid': 'test-user-id'});
    });

    test('Client Newer: Updates server expense', () async {
      final expenseId = 'expense-1';
      final oldTime = DateTime.parse('2023-01-01T10:00:00Z');
      final newTime = DateTime.parse('2023-01-01T12:00:00Z');

      final localChanges = [
        {
          'id': expenseId,
          'name': 'New Name',
          'amount': 100,
          'date': newTime.toIso8601String(),
          'updatedAt': newTime.toIso8601String(),
          'isDeleted': false,
        }
      ];

      final body = {
        'lastSyncAt': oldTime.toIso8601String(),
        'localChanges': localChanges,
      };

      when(() => request.json()).thenAnswer((_) async => body);

      // Mock server having older version
      final serverExpense = Expense(
        id: expenseId,
        userId: 'test-user-id',
        name: 'Old Name',
        amount: 50,
        date: oldTime,
        createdAt: oldTime,
        updatedAt: oldTime,
        isDeleted: false,
      );

      when(() => expenseRepo.getExpensesForSync(
            userId: any(named: 'userId'),
            lastSyncAt: any(named: 'lastSyncAt'),
          )).thenAnswer((_) async => []);

      when(() => expenseRepo.findByIdForSync(expenseId))
          .thenAnswer((_) async => serverExpense);

      when(() => expenseRepo.updateExpense(
            expenseId: any(named: 'expenseId'),
            userId: any(named: 'userId'),
            name: any(named: 'name'),
            amount: any(named: 'amount'),
            date: any(named: 'date'),
            categoryId: any(named: 'categoryId'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => true);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.ok));

      // Verify update was called
      verify(() => expenseRepo.updateExpense(
            expenseId: expenseId,
            userId: 'test-user-id',
            name: 'New Name',
            amount: 100.0,
            date: newTime,
            categoryId: null,
            description: null,
          )).called(1);
    });

    test('Server Newer: Does NOT update server expense (Server Wins)',
        () async {
      final expenseId = 'expense-1';
      final oldTime = DateTime.parse('2023-01-01T10:00:00Z');
      final newTime = DateTime.parse('2023-01-01T12:00:00Z');

      final localChanges = [
        {
          'id': expenseId,
          'name': 'Old Client Name',
          'amount': 50,
          'date': oldTime.toIso8601String(),
          'updatedAt': oldTime.toIso8601String(),
          'isDeleted': false,
        }
      ];

      final body = {
        'lastSyncAt': oldTime.toIso8601String(),
        'localChanges': localChanges,
      };

      when(() => request.json()).thenAnswer((_) async => body);

      // Mock server having NEWER version
      final serverExpense = Expense(
        id: expenseId,
        userId: 'test-user-id',
        name: 'New Server Name',
        amount: 100,
        date: newTime,
        createdAt: oldTime,
        updatedAt: newTime, // Server is newer!
        isDeleted: false,
      );

      when(
        () => expenseRepo.getExpensesForSync(
          userId: any(named: 'userId'),
          lastSyncAt: any(named: 'lastSyncAt'),
        ),
      ).thenAnswer(
        (_) async => [serverExpense],
      ); // Return the newer expense as a change

      when(() => expenseRepo.findByIdForSync(expenseId))
          .thenAnswer((_) async => serverExpense);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.ok));

      // Verify update was NOT called
      verifyNever(
        () => expenseRepo.updateExpense(
          expenseId: any(named: 'expenseId'),
          userId: any(named: 'userId'),
          name: any(named: 'name'),
          amount: any(named: 'amount'),
          date: any(named: 'date'),
          categoryId: any(named: 'categoryId'),
          description: any(named: 'description'),
        ),
      );

      // Verify response contains the server change
      final responseBody = await response.json() as Map<String, dynamic>;
      final data = responseBody['data'] as Map<String, dynamic>;
      final serverChanges = data['serverChanges'] as List;
      expect(serverChanges.length, 1);
      expect(serverChanges[0]['id'], expenseId);
      expect(serverChanges[0]['name'], 'New Server Name');
    });

    test('New Expense: Creates expense and returns ID mapping', () async {
      final newTime = DateTime.parse('2023-01-01T12:00:00Z');

      final localChanges = [
        {
          'id': 'client-id-1',
          'name': 'New Expense',
          'amount': 100,
          'date': newTime.toIso8601String(),
          'updatedAt': newTime.toIso8601String(),
          'isDeleted': false,
        }
      ];

      final body = {
        'lastSyncAt': newTime.subtract(Duration(days: 1)).toIso8601String(),
        'localChanges': localChanges,
      };

      when(() => request.json()).thenAnswer((_) async => body);

      when(() => expenseRepo.getExpensesForSync(
            userId: any(named: 'userId'),
            lastSyncAt: any(named: 'lastSyncAt'),
          )).thenAnswer((_) async => []);

      when(() => expenseRepo.findByIdForSync('client-id-1'))
          .thenAnswer((_) async => null); // Not found on server

      when(() => expenseRepo.createExpense(
            userId: any(named: 'userId'),
            name: any(named: 'name'),
            amount: any(named: 'amount'),
            date: any(named: 'date'),
            categoryId: any(named: 'categoryId'),
            description: any(named: 'description'),
          )).thenAnswer((_) async => Expense(
            id: 'server-id-1',
            userId: 'test-user-id',
            name: 'New Expense',
            amount: 100,
            date: newTime,
            createdAt: newTime,
            updatedAt: newTime,
            isDeleted: false,
          ));

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.ok));

      verify(() => expenseRepo.createExpense(
            userId: 'test-user-id',
            name: 'New Expense',
            amount: 100.0,
            date: newTime,
            categoryId: null,
            description: null,
          )).called(1);

      // Verify ID mapping
      final responseBody = await response.json() as Map<String, dynamic>;
      final data = responseBody['data'] as Map<String, dynamic>;
      final idMapping = data['idMapping'] as Map<String, dynamic>;

      expect(idMapping['client-id-1'], 'server-id-1');
    });

    test('Delete Wins: Ignores update for deleted expense', () async {
      final expenseId = 'expense-1';
      final oldTime = DateTime.parse('2023-01-01T10:00:00Z');
      final newTime = DateTime.parse('2023-01-01T12:00:00Z');

      // Client tries to update a deleted expense
      final localChanges = [
        {
          'id': expenseId,
          'name': 'Resurrected Name',
          'amount': 100,
          'date': newTime.toIso8601String(),
          'updatedAt': newTime.toIso8601String(), // Newer than server
          'isDeleted': false,
        }
      ];

      final body = {
        'lastSyncAt': oldTime.toIso8601String(),
        'localChanges': localChanges,
      };

      when(() => request.json()).thenAnswer((_) async => body);

      // Server has deleted expense
      final serverExpense = Expense(
        id: expenseId,
        userId: 'test-user-id',
        name: 'Old Name',
        amount: 50,
        date: oldTime,
        createdAt: oldTime,
        updatedAt: oldTime,
        isDeleted: true, // DELETED
      );

      when(() => expenseRepo.getExpensesForSync(
            userId: any(named: 'userId'),
            lastSyncAt: any(named: 'lastSyncAt'),
          )).thenAnswer((_) async => []);

      when(() => expenseRepo.findByIdForSync(expenseId))
          .thenAnswer((_) async => serverExpense);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.ok));

      // Verify update was NOT called
      verifyNever(() => expenseRepo.updateExpense(
            expenseId: any(named: 'expenseId'),
            userId: any(named: 'userId'),
            name: any(named: 'name'),
            amount: any(named: 'amount'),
            date: any(named: 'date'),
            categoryId: any(named: 'categoryId'),
            description: any(named: 'description'),
          ));
    });
  });
}
