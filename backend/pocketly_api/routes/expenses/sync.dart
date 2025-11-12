import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

/// POST /expenses/sync - Sync expenses with timestamp-based conflict resolution
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return ApiResponse.methodNotAllowed();
  }

  return _syncExpenses(context);
}

Future<Response> _syncExpenses(RequestContext context) async {
  final expenseRepo = context.read<ExpenseRepository>();
  final categoryRepo = context.read<CategoryRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    final body = await context.request.json() as Map<String, dynamic>;
    final lastSyncAtStr = body['lastSyncAt'] as String?;
    final localChanges = body['localChanges'] as List<dynamic>? ?? [];

    DateTime? lastSyncAt;
    if (lastSyncAtStr != null) {
      try {
        lastSyncAt = DateTime.parse(lastSyncAtStr);
      } catch (e) {
        return ApiResponse.badRequest(
          message: 'Invalid lastSyncAt format. Use ISO 8601 format.',
        );
      }
    }

    // Get server changes (expenses modified after lastSyncAt)
    final serverExpenses = await expenseRepo.getExpensesForSync(
      userId: userId,
      lastSyncAt: lastSyncAt,
    );

    // Process local changes and resolve conflicts
    final conflicts = <Map<String, dynamic>>[];

    for (final localChange in localChanges) {
      final changeMap = localChange as Map<String, dynamic>;
      final expenseId = changeMap['id'] as String?;
      final localUpdatedAtStr = changeMap['updatedAt'] as String?;
      final isDeleted = changeMap['isDeleted'] as bool? ?? false;

      if (expenseId == null || localUpdatedAtStr == null) {
        continue; // Skip invalid entries
      }

      DateTime localUpdatedAt;
      try {
        localUpdatedAt = DateTime.parse(localUpdatedAtStr);
      } catch (e) {
        continue; // Skip invalid timestamps
      }

      // Check if expense exists on server
      final serverExpense = await expenseRepo.findByIdForSync(expenseId);

      if (serverExpense == null) {
        // New expense - accept client change
        if (!isDeleted) {
          // Create new expense
          try {
            final name = changeMap['name'] as String?;
            final amount = changeMap['amount'] as num?;
            final dateStr = changeMap['date'] as String?;
            final categoryId = changeMap['categoryId'] as String?;
            final description = changeMap['description'] as String?;

            if (name != null && amount != null && dateStr != null) {
              final date = DateTime.parse(dateStr);
              await expenseRepo.createExpense(
                userId: userId,
                name: name,
                amount: amount.toDouble(),
                date: date,
                categoryId: categoryId,
                description: description,
              );
            }
          } catch (e) {
            AppLogger.warning('Failed to create expense from sync: $e');
          }
        }
        // If isDeleted and doesn't exist, no action needed
      } else {
        // Expense exists - resolve conflict based on timestamps
        final serverUpdatedAt = serverExpense.updatedAt;

        if (localUpdatedAt.isAfter(serverUpdatedAt)) {
          // Client is newer - accept client change
          if (isDeleted) {
            // Soft delete
            await expenseRepo.deleteExpense(
              expenseId: expenseId,
              userId: userId,
            );
          } else {
            // Update expense
            try {
              final name = changeMap['name'] as String?;
              final amount = changeMap['amount'] as num?;
              final dateStr = changeMap['date'] as String?;
              final categoryId = changeMap['categoryId'] as String?;
              final description = changeMap['description'] as String?;

              await expenseRepo.updateExpense(
                expenseId: expenseId,
                userId: userId,
                name: name,
                amount: amount?.toDouble(),
                date: dateStr != null ? DateTime.parse(dateStr) : null,
                categoryId: categoryId,
                description: description,
              );
            } catch (e) {
              AppLogger.warning('Failed to update expense from sync: $e');
            }
          }
        } else if (localUpdatedAt.isBefore(serverUpdatedAt)) {
          // Server is newer - return server change (will be in serverChanges)
          // No action needed, server change will be returned
        } else {
          // Timestamps are identical - client wins (preserve user's recent action)
          if (isDeleted) {
            await expenseRepo.deleteExpense(
              expenseId: expenseId,
              userId: userId,
            );
          } else {
            try {
              final name = changeMap['name'] as String?;
              final amount = changeMap['amount'] as num?;
              final dateStr = changeMap['date'] as String?;
              final categoryId = changeMap['categoryId'] as String?;
              final description = changeMap['description'] as String?;

              await expenseRepo.updateExpense(
                expenseId: expenseId,
                userId: userId,
                name: name,
                amount: amount?.toDouble(),
                date: dateStr != null ? DateTime.parse(dateStr) : null,
                categoryId: categoryId,
                description: description,
              );
            } catch (e) {
              AppLogger.warning('Failed to update expense from sync: $e');
            }
          }
        }
      }
    }

    // Convert server expenses to response format
    final serverChanges = <Map<String, dynamic>>[];
    for (final expense in serverExpenses) {
      // Get category if present
      final category = expense.categoryId != null
          ? await categoryRepo.findByIdForSync(expense.categoryId!)
          : null;

      final response =
          ExpenseResponse.fromEntityWithCategory(expense, category).toJson();
      serverChanges.add(response);
    }

    return ApiResponse.success(
      data: {
        'serverChanges': serverChanges,
        'conflicts': conflicts,
      },
    );
  } catch (e) {
    AppLogger.error('Sync expenses error: $e');
    return ApiResponse.internalError(message: 'Failed to sync expenses');
  }
}

