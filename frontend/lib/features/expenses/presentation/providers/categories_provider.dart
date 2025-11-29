import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';
import 'package:pocketly/features/expenses/domain/states/categories_state.dart';

class CategoriesNotifier extends Notifier<CategoriesState> {
  late final CategoryHiveRepository _categoryHiveRepository;
  late final CategoryApiRepository _categoryApiRepository;

  @override
  CategoriesState build() {
    _categoryHiveRepository = locator<CategoryHiveRepository>();
    _categoryApiRepository = locator<CategoryApiRepository>();

    // Load from local storage first (offline support)
    Future.microtask(() => loadLocalCategories());

    return const CategoriesState(isLoading: true);
  }

  /// Load categories from local storage
  Future<void> loadLocalCategories() async {
    try {
      state = state.copyWith(isLoading: true);
      final categories = await _categoryHiveRepository.getAllCategories();

      // If no categories in local storage, fetch from backend first
      if (categories.isEmpty) {
        AppLogger.info('No local categories found, fetching from backend...');
        await syncCategories(); // This will handle the backend fetch and fallback
        return; // syncCategories updates state, so we return early
      } else {
        state = state.copyWith(categories: categories, isLoading: false);
      }
    } catch (e) {
      ErrorHandler.logError('Failed to load local categories', e);
      // Fallback to predefined categories
      state = state.copyWith(
        categories: Categories.predefined,
        isLoading: false,
        error: 'Failed to load categories: $e',
      );
    }
  }

  /// Sync categories from backend
  Future<void> syncCategories() async {
    try {
      state = state.copyWith(isLoading: true);

      // Fetch categories from backend
      final apiCategories = await _categoryApiRepository.getAllCategories();

      // Save to local storage
      await _categoryHiveRepository.saveCategories(apiCategories);

      // Convert to domain models
      final categories = apiCategories.map((api) => api.toDomain()).toList();

      // Update state
      state = state.copyWith(
        categories: categories,
        isLoading: false,
        lastSyncedAt: DateTime.now(),
      );
    } catch (e) {
      ErrorHandler.logError('Failed to sync categories', e);

      // Check if this is a network error
      final networkService = locator<NetworkService>();
      final isOnline = await networkService.isConnected;

      if (!isOnline) {
        // Offline: Use predefined categories ONLY as last resort
        AppLogger.warning('No internet connection. Using default categories.');
        state = state.copyWith(
          isLoading: false,
          error: 'No internet connection. Using default categories.',
          categories: Categories.predefined,
        );
      } else {
        // Online but API failed: Check if we have local categories
        final localCategories = await _categoryHiveRepository
            .getAllCategories();

        if (localCategories.isNotEmpty) {
          // Use local categories from previous sync
          AppLogger.info(
            'API failed, using local categories from previous sync',
          );
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to sync categories: $e',
            categories: localCategories,
          );
        } else {
          // No local categories and API failed: Use predefined as fallback
          AppLogger.warning(
            'API failed and no local categories. Using predefined.',
          );
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to sync categories: $e',
            categories: Categories.predefined,
          );
        }
      }
    }
  }

  /// Get category by backend UUID
  Category? getCategoryById(String id) {
    return state.getCategoryById(id);
  }

  /// Get category by name (useful for mapping predefined categories)
  Category? getCategoryByName(String name) {
    return state.getCategoryByName(name);
  }

  /// Get all categories
  List<Category> getAllCategories() {
    return state.categories;
  }

  /// Refresh categories (reload from local + sync from backend)
  Future<void> refresh() async {
    await loadLocalCategories();
    await syncCategories();
  }
}

// Provider
final categoriesProvider =
    NotifierProvider<CategoriesNotifier, CategoriesState>(
      () => CategoriesNotifier(),
    );

// Legacy provider for backward compatibility
final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
  final categoriesState = ref.watch(categoriesProvider);
  return categoriesState.getCategoryById(id);
});
