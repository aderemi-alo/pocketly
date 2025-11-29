import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/models/models.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getCategories(context),
    HttpMethod.post => _createCategory(context),
    _ => Future.value(ApiResponse.methodNotAllowed()),
  };
}

/// GET /categories - Get user's categories (predefined + custom)
Future<Response> _getCategories(RequestContext context) async {
  final categoryRepo = context.read<CategoryRepository>();

  try {
    // Extract user ID from JWT payload
    final payload = context.read<Map<dynamic, dynamic>>();
    final userId = payload['uid'] as String?;

    if (userId == null) {
      return ApiResponse.unauthorized(message: 'Invalid token payload');
    }

    // Get all categories for the user (predefined + custom)
    final categories = await categoryRepo.getPredefinedCategories();

    final response = categories
        .map((category) => CategoryResponse.fromEntity(category).toJson())
        .toList();

    return ApiResponse.success(data: response);
  } catch (e) {
    AppLogger.error('Get categories error: $e');
    return ApiResponse.internalError(message: 'Failed to fetch categories');
  }
}

/// POST /categories - Create a custom category
Future<Response> _createCategory(RequestContext context) async {
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
    final icon = body['icon'] as String?;
    final color = body['color'] as String?;

    // Validate required fields
    if (name == null || name.trim().isEmpty) {
      return ApiResponse.badRequest(message: 'Category name is required');
    }

    if (icon == null || icon.trim().isEmpty) {
      return ApiResponse.badRequest(message: 'Category icon is required');
    }

    if (color == null || color.trim().isEmpty) {
      return ApiResponse.badRequest(message: 'Category color is required');
    }

    // Check if category name already exists for this user
    final nameExists = await categoryRepo.categoryNameExists(
      name: name.trim(),
      userId: userId,
    );

    if (nameExists) {
      return ApiResponse.badRequest(
        message: 'A category with this name already exists',
      );
    }

    // Create the category
    final category = await categoryRepo.createCustomCategory(
      userId: userId,
      name: name.trim(),
      icon: icon.trim(),
      color: color.trim(),
    );

    final response = CategoryResponse.fromEntity(category).toJson();

    return ApiResponse.success(data: response, statusCode: 201);
  } catch (e) {
    AppLogger.error('Create category error: $e');
    return ApiResponse.internalError(message: 'Failed to create category');
  }
}
