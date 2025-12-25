import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _exportUserData(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

/// GET /export - Export all user data in Klyro-compatible format
///
/// Returns a JSON file containing all non-deleted expenses mapped to
/// Klyro's category enum format. Currency defaults to NGN.
Future<Response> _exportUserData(RequestContext context) async {
  final expenseQueryRepo = context.read<ExpenseQueryRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    // Fetch ALL user expenses with categories (no pagination)
    final expensesWithCategories =
        await expenseQueryRepo.getExpensesWithCategories(
      userId: userId,
      sortBy: 'date',
      sortOrder: 'asc',
    );

    // Map to Klyro-compatible format
    final klyroTransactions = expensesWithCategories.map((record) {
      final expense = record.$1;
      final category = record.$2;

      return {
        'id': expense.id,
        'amount': expense.amount,
        'currency': 'NGN', // Default currency as per PRD
        'category': mapCategoryToKlyro(category?.name),
        'note': buildKlyroNote(expense.name, category?.name),
        'date': expense.date.toIso8601String(),
        'createdAt': expense.createdAt.toIso8601String(),
      };
    }).toList();

    final exportData = {
      'version': 1,
      'source': 'pocketly',
      'exportedAt': DateTime.now().toIso8601String(),
      'data': {
        'transactions': klyroTransactions,
      },
    };

    return ApiResponse.success(
      data: exportData,
      message: 'Export completed. ${klyroTransactions.length} transactions.',
    );
  } catch (e) {
    AppLogger.error('Export user data error: $e');
    return ApiResponse.internalError(message: 'Failed to export user data');
  }
}
