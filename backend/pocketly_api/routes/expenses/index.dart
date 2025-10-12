import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getExpenses(context),
    HttpMethod.post => _createExpense(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

/// GET /expenses - Get user's expenses with pagination and filters
Future<Response> _getExpenses(RequestContext context) async {
  final expenseQueryRepo = context.read<ExpenseQueryRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    // Parse query parameters
    final queryParams = context.request.uri.queryParameters;
    final limitStr = queryParams['limit'];
    final offsetStr = queryParams['offset'];
    final categoryId = queryParams['categoryId'];
    final startDateStr = queryParams['startDate'];
    final endDateStr = queryParams['endDate'];
    final includeCategory = queryParams['includeCategory'] == 'true';

    final limit = limitStr != null ? int.tryParse(limitStr) ?? 50 : 50;
    final offset = offsetStr != null ? int.tryParse(offsetStr) ?? 0 : 0;

    // Parse date range if provided
    DateTime? startDate;
    DateTime? endDate;
    if (startDateStr != null || endDateStr != null) {
      try {
        startDate = startDateStr != null ? DateTime.parse(startDateStr) : null;
        endDate = endDateStr != null ? DateTime.parse(endDateStr) : null;
      } catch (e) {
        return ApiResponse.badRequest(
          message: 'Invalid date format. Use ISO 8601 format.',
        );
      }
    }

    List<dynamic> expenseResponses;
    int totalCount;

    // Use flexible query method with all filters
    if (includeCategory) {
      final expensesWithCategories =
          await expenseQueryRepo.getExpensesWithCategories(
        userId: userId,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );

      expenseResponses = expensesWithCategories
          .map(
            (record) => ExpenseResponse.fromEntityWithCategory(
              record.$1,
              record.$2,
            ).toJson(),
          )
          .toList();

      totalCount = await expenseQueryRepo.getExpensesCount(
        userId: userId,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      final expenses = await expenseQueryRepo.findExpenses(
        userId: userId,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );

      expenseResponses =
          expenses.map((e) => ExpenseResponse.fromEntity(e).toJson()).toList();

      totalCount = await expenseQueryRepo.getExpensesCount(
        userId: userId,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      );
    }

    final hasMore = offset + limit < totalCount;
    final page = (offset / limit).floor() + 1;

    return ApiResponse.success(
      data: {
        'expenses': expenseResponses,
        'total': totalCount,
        'page': page,
        'limit': limit,
        'offset': offset,
        'hasMore': hasMore,
      },
    );
  } catch (e) {
    AppLogger.error('Get expenses error: $e');
    return ApiResponse.internalError(message: 'Failed to fetch expenses');
  }
}

/// POST /expenses - Create a new expense
Future<Response> _createExpense(RequestContext context) async {
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
    final name = body['name'] as String?;
    final amount = body['amount'] as num?;
    final dateStr = body['date'] as String?;
    final categoryId = body['categoryId'] as String?;
    final description = body['description'] as String?;

    // Validate required fields
    if (name == null || name.trim().isEmpty) {
      return ApiResponse.badRequest(message: 'Expense name is required');
    }

    if (amount == null || amount <= 0) {
      return ApiResponse.badRequest(
        message: 'Expense amount is required and must be greater than 0',
      );
    }

    if (dateStr == null) {
      return ApiResponse.badRequest(message: 'Expense date is required');
    }

    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (e) {
      return ApiResponse.badRequest(
        message: 'Invalid date format. Use ISO 8601 format.',
      );
    }

    // Validate category if provided
    if (categoryId != null) {
      final category = await categoryRepo.findById(categoryId);
      if (category == null) {
        return ApiResponse.badRequest(message: 'Invalid category ID');
      }
    }

    // Create the expense
    final expense = await expenseRepo.createExpense(
      userId: userId,
      name: name.trim(),
      amount: amount.toDouble(),
      date: date,
      categoryId: categoryId,
      description: description?.trim(),
    );

    // Fetch category details if present
    final category = expense.categoryId != null
        ? await categoryRepo.findById(expense.categoryId!)
        : null;

    final response =
        ExpenseResponse.fromEntityWithCategory(expense, category).toJson();

    return ApiResponse.success(data: response, statusCode: 201);
  } catch (e) {
    AppLogger.error('Create expense error: $e');
    return ApiResponse.internalError(message: 'Failed to create expense');
  }
}
