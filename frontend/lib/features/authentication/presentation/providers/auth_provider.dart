import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/authentication/domain/domain.dart';
import 'package:pocketly/features/authentication/data/data.dart';
import 'package:pocketly/features/expenses/presentation/providers/categories_provider.dart';
import 'package:pocketly/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:pocketly/features/expenses/domain/repo/category_hive_repository.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    locator<ApiClient>(),
    locator<TokenStorageService>(),
  );
});

// Auth state
class AuthState {
  final bool isLoading;
  final String? error;
  final UserModel? user;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserModel? user,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorageService _tokenStorage;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._tokenStorage, this._ref)
    : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final hasTokens = await _tokenStorage.hasValidTokens();
    if (!hasTokens) {
      // No tokens - switch to local mode
      _ref.read(appStateProvider.notifier).setLocalMode();
      return;
    }

    final cachedUser = await _tokenStorage.getUserData();

    // Check if access token is expired
    final isExpired = await _tokenStorage.isAccessTokenExpired();

    if (isExpired) {
      // Try to refresh the token
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await _authRepository.refreshToken(refreshToken);
          // If refresh succeeds, user is authenticated
          await _tokenStorage.saveUserData(response.user);
          state = state.copyWith(isAuthenticated: true, user: response.user);
          _ref.read(appStateProvider.notifier).setOnlineMode();
        } catch (e) {
          // Refresh failed - switch to local mode (don't clear tokens)
          ErrorHandler.logError('Token refresh failed on startup', e);
          state = state.copyWith(isAuthenticated: false);
          _ref.read(appStateProvider.notifier).setLocalMode();
        }
      } else {
        // No refresh token - switch to local mode
        state = state.copyWith(isAuthenticated: false);
        _ref.read(appStateProvider.notifier).setLocalMode();
      }
    } else {
      // Token is still valid
      state = state.copyWith(isAuthenticated: true, user: cachedUser);
      _ref.read(appStateProvider.notifier).setOnlineMode();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final deviceId = await locator<DeviceIdService>().getDeviceId();
      final request = LoginRequest(
        email: email,
        password: password,
        deviceId: deviceId,
      );

      final response = await _authRepository.login(request);

      await _tokenStorage.saveUserData(response.user);
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id!,
      );

      state = state.copyWith(
        isLoading: false,
        user: response.user,
        isAuthenticated: true,
      );
      _ref.read(appStateProvider.notifier).setOnlineMode();

      // Fetch all data from server after successful login
      try {
        // Fetch categories first
        await _ref.read(categoriesProvider.notifier).syncCategories();

        // Fetch all expenses from server and populate Hive
        await _fetchAndPopulateExpenses();
      } catch (e) {
        ErrorHandler.logError('Failed to fetch data on login', e);
        // Don't fail login if data fetch fails - user can use refresh button
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final deviceId = await locator<DeviceIdService>().getDeviceId();
      final request = LoginRequest(
        name: name,
        email: email,
        password: password,
        deviceId: deviceId,
      );

      final response = await _authRepository.register(request);
      await _tokenStorage.saveUserData(response.user);
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: response.user.id!,
      );

      state = state.copyWith(
        isLoading: false,
        user: response.user,
        isAuthenticated: true,
      );
      _ref.read(appStateProvider.notifier).setOnlineMode();

      // Fetch initial data from server after successful registration
      try {
        await _ref.read(categoriesProvider.notifier).syncCategories();
        await _fetchAndPopulateExpenses();
      } catch (e) {
        ErrorHandler.logError('Failed to fetch data on registration', e);
        // Don't fail registration if data fetch fails
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.logout();
      await _tokenStorage.clearUserData();
      await _tokenStorage.clearTokens();

      // Clear all Hive data on logout
      await expenseHiveRepository.clearAllExpenses();
      final categoryRepo = locator<CategoryHiveRepository>();
      await categoryRepo.clearAll();

      state = const AuthState();
      _ref.read(appStateProvider.notifier).setLocalMode();
    } catch (e) {
      // Clear state even if logout fails
      await _tokenStorage.clearUserData();
      await _tokenStorage.clearTokens();

      // Clear Hive data even if logout fails
      await expenseHiveRepository.clearAllExpenses();
      final categoryRepo = locator<CategoryHiveRepository>();
      await categoryRepo.clearAll();

      state = const AuthState();
      _ref.read(appStateProvider.notifier).setLocalMode();
    }
  }

  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.updatePassword(currentPassword, newPassword);

      // Logout after successful password change
      await logout();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUserEmailVerification(bool isVerified) async {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(isEmailVerified: isVerified);
      await _tokenStorage.saveUserData(updatedUser);
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> updateUserName(String name) async {
    state = state.copyWith(isLoading: true);

    try {
      final request = UpdateProfileRequest(name: name);
      final updatedUser = await _authRepository.updateProfile(request);

      state = state.copyWith(isLoading: false, user: updatedUser);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshUserProfile() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await _authRepository.fetchUserProfile();

      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAccount({String? password}) async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.deleteAccount(password);

      // Clear all local data after successful deletion
      await _tokenStorage.clearUserData();
      await _tokenStorage.clearTokens();

      // Clear lastSyncTime on account deletion
      _ref.read(appStateProvider.notifier).updateLastSyncTime(null);

      // Reset state and switch to local mode
      state = const AuthState();
      _ref.read(appStateProvider.notifier).setLocalMode();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Fetch all expenses from server and populate Hive
  Future<void> _fetchAndPopulateExpenses() async {
    try {
      final expenseApi = expenseApiRepository;

      // Fetch all expenses from server (pagination might be needed later)
      final result = await expenseApi.getExpenses(
        limit: 1000, // Large enough to get all expenses for now
        offset: 0,
        includeCategory: true,
      );

      final expenses = result['expenses'] as List<dynamic>;

      // Trigger expenses refresh to load newly fetched data from server
      // The expenses provider will re-fetch from Hive after this
      if (mounted) {
        await _ref.read(expensesProvider.notifier).refreshExpenses();
      }

      AppLogger.info('Fetched ${expenses.length} expenses from server');
    } catch (e) {
      ErrorHandler.logError('Failed to fetch expenses from server', e);
      rethrow;
    }
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    locator<TokenStorageService>(),
    ref,
  );
});
