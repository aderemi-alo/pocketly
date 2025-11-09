import 'package:pocketly/features/expenses/data/models/category_hive.dart';
import 'package:pocketly/features/expenses/data/models/category_api_model.dart';
import 'package:pocketly/features/expenses/domain/models/category.dart';
import 'package:pocketly/features/expenses/data/database/hive_database.dart';

class CategoryHiveRepository {
  /// Get all categories from local storage
  Future<List<Category>> getAllCategories() async {
    final box = HiveDatabase.categoryBox;
    final categoryHives = box.values.toList();
    return categoryHives.map((hive) => hive.toDomain()).toList();
  }

  /// Get category by backend UUID
  Future<Category?> getCategoryById(String id) async {
    final box = HiveDatabase.categoryBox;
    final categoryHive = box.get(id);
    return categoryHive?.toDomain();
  }

  /// Get category by name (useful for mapping predefined categories)
  Future<Category?> getCategoryByName(String name) async {
    final box = HiveDatabase.categoryBox;
    final categoryHive = box.values.firstWhere(
      (hive) => hive.name.toLowerCase() == name.toLowerCase(),
      orElse: () => throw StateError('Category not found'),
    );
    return categoryHive.toDomain();
  }

  /// Get category by name (returns null if not found)
  Future<Category?> getCategoryByNameOrNull(String name) async {
    try {
      return await getCategoryByName(name);
    } catch (e) {
      return null;
    }
  }

  /// Save multiple categories from API models
  Future<void> saveCategories(List<CategoryApiModel> categories) async {
    final box = HiveDatabase.categoryBox;
    for (final category in categories) {
      final categoryHive = CategoryHive.fromApiModel(category);
      await box.put(categoryHive.id, categoryHive);
    }
  }

  /// Save a single category from API model
  Future<void> saveCategory(CategoryApiModel category) async {
    final box = HiveDatabase.categoryBox;
    final categoryHive = CategoryHive.fromApiModel(category);
    await box.put(categoryHive.id, categoryHive);
  }

  /// Delete a category by ID
  Future<void> deleteCategory(String id) async {
    final box = HiveDatabase.categoryBox;
    await box.delete(id);
  }

  /// Clear all categories
  Future<void> clearAll() async {
    final box = HiveDatabase.categoryBox;
    await box.clear();
  }

  /// Check if category exists by ID
  Future<bool> categoryExists(String id) async {
    final box = HiveDatabase.categoryBox;
    return box.containsKey(id);
  }

  /// Get all predefined categories
  Future<List<Category>> getPredefinedCategories() async {
    final box = HiveDatabase.categoryBox;
    final categoryHives = box.values
        .where((hive) => hive.isPredefined)
        .toList();
    return categoryHives.map((hive) => hive.toDomain()).toList();
  }

  /// Get all custom categories
  Future<List<Category>> getCustomCategories() async {
    final box = HiveDatabase.categoryBox;
    final categoryHives = box.values
        .where((hive) => !hive.isPredefined)
        .toList();
    return categoryHives.map((hive) => hive.toDomain()).toList();
  }
}

