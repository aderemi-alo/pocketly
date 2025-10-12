import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context, String categoryId) async {
  return switch (context.request.method) {
    HttpMethod.get => _getCategory(context, categoryId),
    HttpMethod.put => _updateCategory(context, categoryId),
    HttpMethod.delete => _deleteCategory(context, categoryId),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

/// GET /categories/[categoryId] - Get a specific category
Future<Response> _getCategory(
  RequestContext context,
  String categoryId,
) async {
  final categoryRepo = context.read<CategoryRepository>();

  try {
    final category = await categoryRepo.findById(categoryId);

    if (category == null) {
      return ApiResponse.notFound(message: 'Category not found');
    }

    final response = CategoryResponse.fromEntity(category).toJson();

    return ApiResponse.success(data: response);
  } catch (e) {
    AppLogger.error('Get category error: $e');
    return ApiResponse.internalError(message: 'Failed to fetch category');
  }
}

/// PUT /categories/[categoryId] - Update a custom category
Future<Response> _updateCategory(
  RequestContext context,
  String categoryId,
) async {
  final categoryRepo = context.read<CategoryRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    // Verify the category exists and belongs to the user
    final category = await categoryRepo.findById(categoryId);

    if (category == null) {
      return ApiResponse.notFound(message: 'Category not found');
    }

    // Check if this is a predefined category (can't be updated)
    if (category.userId == null) {
      return ApiResponse.forbidden(
        message: 'Predefined categories cannot be updated',
      );
    }

    // Check if the category belongs to the user
    if (category.userId != userId) {
      return ApiResponse.forbidden(
        message: 'You do not have permission to update this category',
      );
    }

    final body = await context.request.json() as Map<String, dynamic>;
    final name = body['name'] as String?;
    final icon = body['icon'] as String?;
    final color = body['color'] as String?;

    // At least one field should be provided for update
    if (name == null && icon == null && color == null) {
      return ApiResponse.badRequest(
        message: 'At least one field (name, icon, or color) must be provided',
      );
    }

    // Check if new name conflicts with existing categories
    if (name != null && name.trim() != category.name) {
      final nameExists = await categoryRepo.categoryNameExists(
        name: name.trim(),
        userId: userId,
      );

      if (nameExists) {
        return ApiResponse.badRequest(
          message: 'A category with this name already exists',
        );
      }
    }

    // Update the category
    final success = await categoryRepo.updateCustomCategory(
      categoryId: categoryId,
      userId: userId,
      name: name?.trim(),
      icon: icon?.trim(),
      color: color?.trim(),
    );

    if (!success) {
      return ApiResponse.internalError(message: 'Failed to update category');
    }

    // Fetch and return the updated category
    final updatedCategory = await categoryRepo.findById(categoryId);

    if (updatedCategory == null) {
      return ApiResponse.internalError(
        message: 'Failed to fetch updated category',
      );
    }

    final response = CategoryResponse.fromEntity(updatedCategory).toJson();

    return ApiResponse.success(data: response);
  } catch (e) {
    AppLogger.error('Update category error: $e');
    return ApiResponse.internalError(message: 'Failed to update category');
  }
}

/// DELETE /categories/[categoryId] - Delete a custom category
Future<Response> _deleteCategory(
  RequestContext context,
  String categoryId,
) async {
  final categoryRepo = context.read<CategoryRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    // Verify the category exists and belongs to the user
    final category = await categoryRepo.findById(categoryId);

    if (category == null) {
      return ApiResponse.notFound(message: 'Category not found');
    }

    // Check if this is a predefined category (can't be deleted)
    if (category.userId == null) {
      return ApiResponse.forbidden(
        message: 'Predefined categories cannot be deleted',
      );
    }

    // Check if the category belongs to the user
    if (category.userId != userId) {
      return ApiResponse.forbidden(
        message: 'You do not have permission to delete this category',
      );
    }

    // Delete the category
    final success = await categoryRepo.deleteCustomCategory(
      categoryId: categoryId,
      userId: userId,
    );

    if (!success) {
      return ApiResponse.internalError(message: 'Failed to delete category');
    }

    return ApiResponse.success(
      data: {'message': 'Category deleted successfully'},
    );
  } catch (e) {
    AppLogger.error('Delete category error: $e');
    return ApiResponse.internalError(message: 'Failed to delete category');
  }
}
