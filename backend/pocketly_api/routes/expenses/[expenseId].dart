import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context, String expenseId) async {
  return switch (context.request.method) {
    HttpMethod.get => _getExpense(context, expenseId),
    HttpMethod.put => _updateExpense(context, expenseId),
    HttpMethod.delete => _deleteExpense(context, expenseId),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

/// GET /expenses/[expenseId] - Get a specific expense
Future<Response> _getExpense(
  RequestContext context,
  String expenseId,
) async {
  final expenseQueryRepo = context.read<ExpenseQueryRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    // Get expense with category details
    final result = await expenseQueryRepo.getExpenseWithCategory(expenseId);

    if (result == null) {
      return ApiResponse.notFound(message: 'Expense not found');
    }

    final (expense, category) = result;

    // Verify the expense belongs to the user
    if (expense.userId != userId) {
      return ApiResponse.forbidden(
        message: 'You do not have permission to view this expense',
      );
    }

    final response =
        ExpenseResponse.fromEntityWithCategory(expense, category).toJson();

    return ApiResponse.success(data: response);
  } catch (e) {
    AppLogger.error('Get expense error: $e');
    return ApiResponse.internalError(message: 'Failed to fetch expense');
  }
}

/// PUT /expenses/[expenseId] - Update an expense
Future<Response> _updateExpense(
  RequestContext context,
  String expenseId,
) async {
  final expenseRepo = context.read<ExpenseRepository>();
  final categoryRepo = context.read<CategoryRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    // Verify the expense exists and belongs to the user
    final expense = await expenseRepo.findById(expenseId);

    if (expense == null) {
      return ApiResponse.notFound(message: 'Expense not found');
    }

    if (expense.userId != userId) {
      return ApiResponse.forbidden(
        message: 'You do not have permission to update this expense',
      );
    }

    final body = await context.request.json() as Map<String, dynamic>;
    final name = body['name'] as String?;
    final amount = body['amount'] as num?;
    final dateStr = body['date'] as String?;
    final categoryId = body['categoryId'] as String?;
    final description = body['description'] as String?;
    final currency = (body['currency'] as String?)?.toUpperCase();

    // Validate amount if provided
    if (amount != null && amount <= 0) {
      return ApiResponse.badRequest(
        message: 'Expense amount must be greater than 0',
      );
    }

    // Parse date if provided
    DateTime? date;
    if (dateStr != null) {
      try {
        date = DateTime.parse(dateStr);
      } catch (e) {
        return ApiResponse.badRequest(
          message: 'Invalid date format. Use ISO 8601 format.',
        );
      }
    }

    // Validate category if provided
    if (categoryId != null) {
      final category = await categoryRepo.findById(categoryId);
      if (category == null) {
        return ApiResponse.badRequest(message: 'Invalid category ID');
      }
    }

    // Validate currency if provided
    if (currency != null && !isValidCurrency(currency)) {
      return ApiResponse.badRequest(
        message:
            'Invalid currency code. Supported: ${supportedCurrencies.join(", ")}',
      );
    }

    // At least one field should be provided for update
    if (name == null &&
        amount == null &&
        date == null &&
        categoryId == null &&
        description == null &&
        currency == null) {
      return ApiResponse.badRequest(
        message: 'At least one field must be provided for update',
      );
    }

    // Update the expense
    final success = await expenseRepo.updateExpense(
      expenseId: expenseId,
      userId: userId,
      name: name?.trim(),
      amount: amount?.toDouble(),
      date: date,
      categoryId: categoryId,
      description: description?.trim(),
      currency: currency,
    );

    if (!success) {
      return ApiResponse.internalError(message: 'Failed to update expense');
    }

    // Fetch and return the updated expense with category details
    final expenseQueryRepo = context.read<ExpenseQueryRepository>();
    final result = await expenseQueryRepo.getExpenseWithCategory(expenseId);

    if (result == null) {
      return ApiResponse.internalError(
        message: 'Failed to fetch updated expense',
      );
    }

    final (updatedExpense, category) = result;

    final response =
        ExpenseResponse.fromEntityWithCategory(updatedExpense, category)
            .toJson();

    return ApiResponse.success(data: response);
  } catch (e) {
    AppLogger.error('Update expense error: $e');
    return ApiResponse.internalError(message: 'Failed to update expense');
  }
}

/// DELETE /expenses/[expenseId] - Delete an expense
Future<Response> _deleteExpense(
  RequestContext context,
  String expenseId,
) async {
  final expenseRepo = context.read<ExpenseRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    // Verify the expense exists and belongs to the user
    final expense = await expenseRepo.findById(expenseId);

    if (expense == null) {
      return ApiResponse.notFound(message: 'Expense not found');
    }

    if (expense.userId != userId) {
      return ApiResponse.forbidden(
        message: 'You do not have permission to delete this expense',
      );
    }

    // Delete the expense
    final success = await expenseRepo.deleteExpense(
      expenseId: expenseId,
      userId: userId,
    );

    if (!success) {
      return ApiResponse.internalError(message: 'Failed to delete expense');
    }

    return ApiResponse.success(
      data: {'message': 'Expense deleted successfully'},
    );
  } catch (e) {
    AppLogger.error('Delete expense error: $e');
    return ApiResponse.internalError(message: 'Failed to delete expense');
  }
}
