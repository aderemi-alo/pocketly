import 'package:pocketly/core/services/api_client.dart';
import 'package:pocketly/features/expenses/data/models/expense_api_model.dart';
import 'package:pocketly/features/expenses/data/models/expense_stats_model.dart';

class ExpenseApiRepository {
  final ApiClient _apiClient;

  ExpenseApiRepository(this._apiClient);

  Future<Map<String, dynamic>> getExpenses({
    int limit = 50,
    int offset = 0,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeCategory = true,
  }) async {
    final response = await _apiClient.dio.get(
      '/expenses',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        if (categoryId != null) 'categoryId': categoryId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        'includeCategory': includeCategory,
      },
    );

    final data = response.data['data'];
    return {
      'expenses': (data['expenses'] as List)
          .map((json) => ExpenseApiModel.fromJson(json))
          .toList(),
      'total': data['total'],
      'hasMore': data['hasMore'],
      'limit': data['limit'],
      'offset': data['offset'],
    };
  }

  Future<ExpenseApiModel> getExpenseById(String expenseId) async {
    final response = await _apiClient.dio.get('/expenses/$expenseId');
    return ExpenseApiModel.fromJson(response.data['data']);
  }

  Future<ExpenseApiModel> createExpense({
    required String name,
    required double amount,
    required DateTime date,
    required String categoryId,
    String? description,
  }) async {
    final response = await _apiClient.dio.post(
      '/expenses',
      data: {
        'name': name,
        'amount': amount,
        'date': date.toIso8601String(),
        'categoryId': categoryId,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    return ExpenseApiModel.fromJson(response.data['data']);
  }

  Future<ExpenseApiModel> updateExpense({
    required String expenseId,
    String? name,
    double? amount,
    DateTime? date,
    String? categoryId,
    String? description,
  }) async {
    final response = await _apiClient.dio.put(
      '/expenses/$expenseId',
      data: {
        if (name != null) 'name': name,
        if (amount != null) 'amount': amount,
        if (date != null) 'date': date.toIso8601String(),
        if (categoryId != null) 'categoryId': categoryId,
        if (description != null) 'description': description,
      },
    );
    return ExpenseApiModel.fromJson(response.data['data']);
  }

  Future<void> deleteExpense(String expenseId) async {
    await _apiClient.dio.delete('/expenses/$expenseId');
  }

  Future<ExpenseStatsModel> getStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _apiClient.dio.get(
      '/expenses/stats',
      queryParameters: {
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      },
    );
    return ExpenseStatsModel.fromJson(response.data['data']);
  }
}
