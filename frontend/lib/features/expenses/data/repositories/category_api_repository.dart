import 'package:pocketly/core/services/api_client.dart';
import 'package:pocketly/features/expenses/data/models/category_api_model.dart';

class CategoryApiRepository {
  final ApiClient _apiClient;

  CategoryApiRepository(this._apiClient);

  Future<List<CategoryApiModel>> getAllCategories() async {
    final response = await _apiClient.dio.get('/categories');
    final List data = response.data['data'];
    return data.map((json) => CategoryApiModel.fromJson(json)).toList();
  }

  Future<CategoryApiModel> getCategoryById(String categoryId) async {
    final response = await _apiClient.dio.get('/categories/$categoryId');
    return CategoryApiModel.fromJson(response.data['data']);
  }

  Future<CategoryApiModel> createCategory({
    required String name,
    required String icon,
    required String color,
  }) async {
    final response = await _apiClient.dio.post(
      '/categories',
      data: {'name': name, 'icon': icon, 'color': color},
    );
    return CategoryApiModel.fromJson(response.data['data']);
  }

  Future<CategoryApiModel> updateCategory({
    required String categoryId,
    String? name,
    String? icon,
    String? color,
  }) async {
    final response = await _apiClient.dio.put(
      '/categories/$categoryId',
      data: {
        if (name != null) 'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
      },
    );
    return CategoryApiModel.fromJson(response.data['data']);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _apiClient.dio.delete('/categories/$categoryId');
  }

  /// Sync categories with server
  /// Returns server changes and conflicts
  Future<Map<String, dynamic>> syncCategories({
    DateTime? lastSyncAt,
    required List<Map<String, dynamic>> localChanges,
  }) async {
    final response = await _apiClient.dio.post(
      '/categories/actions/sync',
      data: {
        if (lastSyncAt != null) 'lastSyncAt': lastSyncAt.toIso8601String(),
        'localChanges': localChanges,
      },
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}
