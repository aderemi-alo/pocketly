import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getAnalytics(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

/// GET /expenses/stats - Get expense statistics and analytics
Future<Response> _getAnalytics(RequestContext context) async {
  final expenseQueryRepo = context.read<ExpenseQueryRepository>();
  final expenseAnalyticsRepo = context.read<ExpenseAnalyticsRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    // Parse query parameters for date range
    final queryParams = context.request.uri.queryParameters;
    final startDateStr = queryParams['startDate'];
    final endDateStr = queryParams['endDate'];

    Map<String, dynamic> stats;

    // Stats for date range
    if (startDateStr != null && endDateStr != null) {
      try {
        final startDate = DateTime.parse(startDateStr);
        final endDate = DateTime.parse(endDateStr);

        final total = await expenseAnalyticsRepo.getTotalExpensesAmount(
          userId,
          startDate: startDate,
          endDate: endDate,
        );

        final expensesCount = await expenseQueryRepo.getExpensesCount(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        );

        final categoryBreakdown =
            await expenseAnalyticsRepo.getCategoryBreakdown(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        );

        // Calculate daily average
        final daysDifference = endDate.difference(startDate).inDays + 1;
        final dailyAverage = daysDifference > 0 ? total / daysDifference : 0.0;

        stats = {
          'total': total,
          'count': expensesCount,
          'categoryBreakdown': categoryBreakdown,
          'dailyAverage': dailyAverage,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'period': 'custom',
        };
      } catch (e) {
        return ApiResponse.badRequest(
          message: 'Invalid date format. Use ISO 8601 format.',
        );
      }
    }
    // Overall stats
    else {
      final total = await expenseAnalyticsRepo.getTotalExpensesAmount(userId);
      final expensesCount = await expenseQueryRepo.getExpensesCount(
        userId: userId,
      );
      final categoryBreakdown =
          await expenseAnalyticsRepo.getCategoryBreakdown(userId: userId);

      // Calculate average (total / number of expenses, not daily)
      final average = expensesCount > 0 ? total / expensesCount : 0.0;

      stats = {
        'total': total,
        'count': expensesCount,
        'categoryBreakdown': categoryBreakdown,
        'averagePerExpense': average,
        'period': 'all',
      };
    }

    return ApiResponse.success(data: stats);
  } catch (e) {
    AppLogger.error('Get stats error: $e');
    return ApiResponse.internalError(message: 'Failed to fetch statistics');
  }
}
