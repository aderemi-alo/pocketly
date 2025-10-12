import 'package:drift/drift.dart';
import 'package:pocketly_api/database/database.dart';

/// Repository for category-related operations
class CategoryRepository {
  /// Creates an instance of [CategoryRepository]
  const CategoryRepository(this._db);

  final PocketlyDatabase _db;

  /// Gets all predefined categories (system categories)
  Future<List<Category>> getPredefinedCategories() async {
    return (_db.select(_db.categories)..where((c) => c.userId.isNull())).get();
  }

  /// Gets all categories for a specific user (includes predefined + custom)
  Future<List<Category>> getUserCategories(String userId) async {
    return (_db.select(_db.categories)
          ..where(
            (c) => c.userId.isNull() | c.userId.equals(userId),
          ))
        .get();
  }

  /// Gets a category by ID
  Future<Category?> findById(String categoryId) async {
    return (_db.select(_db.categories)..where((c) => c.id.equals(categoryId)))
        .getSingleOrNull();
  }

  /// Creates a custom category for a user
  Future<Category> createCustomCategory({
    required String userId,
    required String name,
    required String icon,
    required String color,
  }) async {
    final now = DateTime.now();

    final companion = CategoriesCompanion.insert(
      name: name,
      icon: icon,
      color: color,
      userId: Value(userId),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.into(_db.categories).insert(companion);

    // Fetch and return the newly created category
    return (_db.select(_db.categories)
          ..where((c) => c.name.equals(name))
          ..where((c) => c.userId.equals(userId)))
        .getSingle();
  }

  /// Updates a custom category
  /// Only user-created categories can be updated
  Future<bool> updateCustomCategory({
    required String categoryId,
    required String userId,
    String? name,
    String? icon,
    String? color,
  }) async {
    final updateCompanion = CategoriesCompanion(
      id: Value(categoryId),
      name: name != null ? Value(name) : const Value.absent(),
      icon: icon != null ? Value(icon) : const Value.absent(),
      color: color != null ? Value(color) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    final updatedCount = await (_db.update(_db.categories)
          ..where((c) => c.id.equals(categoryId))
          ..where((c) => c.userId.equals(userId)))
        .write(updateCompanion);

    return updatedCount > 0;
  }

  /// Deletes a custom category
  /// Only user-created categories can be deleted
  Future<bool> deleteCustomCategory({
    required String categoryId,
    required String userId,
  }) async {
    final deletedCount = await (_db.delete(_db.categories)
          ..where((c) => c.id.equals(categoryId))
          ..where((c) => c.userId.equals(userId)))
        .go();

    return deletedCount > 0;
  }

  /// Checks if a category name already exists for a user
  Future<bool> categoryNameExists({
    required String name,
    String? userId,
  }) async {
    final query = _db.select(_db.categories)..where((c) => c.name.equals(name));

    if (userId != null) {
      query.where((c) => c.userId.isNull() | c.userId.equals(userId));
    } else {
      query.where((c) => c.userId.isNull());
    }

    final category = await query.getSingleOrNull();
    return category != null;
  }
}
