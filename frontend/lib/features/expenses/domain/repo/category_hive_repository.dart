import 'package:pocketly/features/expenses/data/models/category_hive.dart';
import 'package:pocketly/features/expenses/data/models/category_api_model.dart';
import 'package:pocketly/features/expenses/domain/models/category.dart';
import 'package:pocketly/features/expenses/data/database/hive_database.dart';

class CategoryHiveRepository {
  /// Get all categories from local storage (excluding deleted)
  Future<List<Category>> getAllCategories() async {
    final box = HiveDatabase.categoryBox;
    final categoryHives = box.values
        .where((hive) => !hive.isDeleted)
        .toList();
    return categoryHives.map((hive) => hive.toDomain()).toList();
  }

  /// Get all categories for sync (including deleted)
  Future<List<Category>> getAllCategoriesForSync() async {
    final box = HiveDatabase.categoryBox;
    final categoryHives = box.values.toList();
    return categoryHives.map((hive) => hive.toDomain()).toList();
  }

  /// Get category by backend UUID (excluding deleted)
  Future<Category?> getCategoryById(String id) async {
    final box = HiveDatabase.categoryBox;
    final categoryHive = box.get(id);
    if (categoryHive == null || categoryHive.isDeleted) return null;
    return categoryHive.toDomain();
  }

  /// Get category by name (useful for mapping predefined categories, excluding deleted)
  Future<Category?> getCategoryByName(String name) async {
    final box = HiveDatabase.categoryBox;
    final categoryHive = box.values.firstWhere(
      (hive) => !hive.isDeleted && hive.name.toLowerCase() == name.toLowerCase(),
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

  /// Soft delete a category by ID (sets isDeleted = true)
  Future<void> deleteCategory(String id) async {
    final box = HiveDatabase.categoryBox;
    final categoryHive = box.get(id);
    if (categoryHive != null) {
      final deletedCategory = CategoryHive.create(
        id: categoryHive.id,
        name: categoryHive.name,
        icon: categoryHive.icon,
        color: categoryHive.color,
        isPredefined: categoryHive.isPredefined,
        userId: categoryHive.userId,
        syncedAt: categoryHive.syncedAt,
        updatedAt: DateTime.now(),
        isDeleted: true,
      );
      await box.put(id, deletedCategory);
    }
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

  /// Get all predefined categories (excluding deleted)
  Future<List<Category>> getPredefinedCategories() async {
    final box = HiveDatabase.categoryBox;
    final categoryHives = box.values
        .where((hive) => hive.isPredefined && !hive.isDeleted)
        .toList();
    return categoryHives.map((hive) => hive.toDomain()).toList();
  }

  /// Get all custom categories (excluding deleted)
  Future<List<Category>> getCustomCategories() async {
    final box = HiveDatabase.categoryBox;
    final categoryHives = box.values
        .where((hive) => !hive.isPredefined && !hive.isDeleted)
        .toList();
    return categoryHives.map((hive) => hive.toDomain()).toList();
  }
}

