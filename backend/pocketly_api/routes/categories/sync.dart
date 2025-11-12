import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

/// POST /categories/sync - Sync categories with timestamp-based conflict resolution
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return ApiResponse.methodNotAllowed();
  }

  return _syncCategories(context);
}

Future<Response> _syncCategories(RequestContext context) async {
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

    // Get server changes (categories modified after lastSyncAt)
    final serverCategories = await categoryRepo.getCategoriesForSync(
      userId: userId,
      lastSyncAt: lastSyncAt,
    );

    // Process local changes and resolve conflicts
    final conflicts = <Map<String, dynamic>>[];

    for (final localChange in localChanges) {
      final changeMap = localChange as Map<String, dynamic>;
      final categoryId = changeMap['id'] as String?;
      final localUpdatedAtStr = changeMap['updatedAt'] as String?;
      final isDeleted = changeMap['isDeleted'] as bool? ?? false;

      if (categoryId == null || localUpdatedAtStr == null) {
        continue; // Skip invalid entries
      }

      DateTime localUpdatedAt;
      try {
        localUpdatedAt = DateTime.parse(localUpdatedAtStr);
      } catch (e) {
        continue; // Skip invalid timestamps
      }

      // Check if category exists on server
      final serverCategory = await categoryRepo.findByIdForSync(categoryId);

      if (serverCategory == null) {
        // New category - accept client change (only for user categories)
        if (!isDeleted) {
          try {
            final name = changeMap['name'] as String?;
            final icon = changeMap['icon'] as String?;
            final color = changeMap['color'] as String?;

            if (name != null && icon != null && color != null) {
              await categoryRepo.createCustomCategory(
                userId: userId,
                name: name,
                icon: icon,
                color: color,
              );
            }
          } catch (e) {
            AppLogger.warning('Failed to create category from sync: $e');
          }
        }
        // If isDeleted and doesn't exist, no action needed
      } else {
        // Category exists - resolve conflict based on timestamps
        // Only allow updates/deletes for user-created categories
        if (serverCategory.userId == null) {
          continue; // Skip predefined categories
        }

        final serverUpdatedAt = serverCategory.updatedAt;

        if (localUpdatedAt.isAfter(serverUpdatedAt)) {
          // Client is newer - accept client change
          if (isDeleted) {
            // Soft delete
            await categoryRepo.deleteCustomCategory(
              categoryId: categoryId,
              userId: userId,
            );
          } else {
            // Update category
            try {
              final name = changeMap['name'] as String?;
              final icon = changeMap['icon'] as String?;
              final color = changeMap['color'] as String?;

              await categoryRepo.updateCustomCategory(
                categoryId: categoryId,
                userId: userId,
                name: name,
                icon: icon,
                color: color,
              );
            } catch (e) {
              AppLogger.warning('Failed to update category from sync: $e');
            }
          }
        } else if (localUpdatedAt.isBefore(serverUpdatedAt)) {
          // Server is newer - return server change (will be in serverChanges)
          // No action needed, server change will be returned
        } else {
          // Timestamps are identical - client wins (preserve user's recent action)
          if (isDeleted) {
            await categoryRepo.deleteCustomCategory(
              categoryId: categoryId,
              userId: userId,
            );
          } else {
            try {
              final name = changeMap['name'] as String?;
              final icon = changeMap['icon'] as String?;
              final color = changeMap['color'] as String?;

              await categoryRepo.updateCustomCategory(
                categoryId: categoryId,
                userId: userId,
                name: name,
                icon: icon,
                color: color,
              );
            } catch (e) {
              AppLogger.warning('Failed to update category from sync: $e');
            }
          }
        }
      }
    }

    // Convert server categories to response format
    final serverChanges = serverCategories
        .map((category) => CategoryResponse.fromEntity(category).toJson())
        .toList();

    return ApiResponse.success(
      data: {
        'serverChanges': serverChanges,
        'conflicts': conflicts,
      },
    );
  } catch (e) {
    AppLogger.error('Sync categories error: $e');
    return ApiResponse.internalError(message: 'Failed to sync categories');
  }
}
