import 'package:pocketly/features/expenses/domain/models/category.dart';

class CategoriesState {
  final List<Category> categories;
  final bool isLoading;
  final String? error;
  final DateTime? lastSyncedAt;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.lastSyncedAt,
  });

  CategoriesState copyWith({
    List<Category>? categories,
    bool? isLoading,
    String? error,
    DateTime? lastSyncedAt,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Get predefined categories
  List<Category> get predefinedCategories {
    // For now, return all categories marked as predefined
    // This will be enhanced when we have isPredefined flag in Category model
    return categories;
  }

  /// Get custom categories
  List<Category> get customCategories {
    // For now, return empty list
    // This will be enhanced when we have custom categories
    return [];
  }

  /// Get category by ID
  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get category by name (case-insensitive)
  Category? getCategoryByName(String name) {
    try {
      return categories.firstWhere(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
