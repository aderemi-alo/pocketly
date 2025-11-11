import 'package:pocketly/core/core.dart';
import 'package:pocketly/core/services/logger_service.dart';
import 'package:pocketly/core/utils/error_handler.dart';
import 'package:pocketly/features/authentication/domain/domain.dart';
import 'package:pocketly/features/authentication/data/data.dart';
import 'package:pocketly/core/providers/app_state_provider.dart';
import 'package:pocketly/features/expenses/presentation/providers/categories_provider.dart';

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

      // Sync categories from backend after successful login
      try {
        await _ref.read(categoriesProvider.notifier).syncCategories();
      } catch (e) {
        ErrorHandler.logError('Failed to sync categories on login', e);
        // Don't fail login if category sync fails
      }

      // Process pending sync queue after successful login
      await _processPendingSyncQueue();
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

      // Sync categories from backend after successful registration
      try {
        await _ref.read(categoriesProvider.notifier).syncCategories();
      } catch (e) {
        ErrorHandler.logError('Failed to sync categories on registration', e);
        // Don't fail registration if category sync fails
      }

      // Process pending sync queue after successful registration
      await _processPendingSyncQueue();
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
      state = const AuthState();
      _ref.read(appStateProvider.notifier).setLocalMode();
    } catch (e) {
      // Clear state even if logout fails
      await _tokenStorage.clearUserData();
      await _tokenStorage.clearTokens();
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

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Process pending sync queue after login
  Future<void> _processPendingSyncQueue() async {
    try {
      // TODO: Implement sync queue processing
      // This would trigger the sync manager to process pending items
      AppLogger.debug('Processing pending sync queue...');

      // Update pending sync count
      final syncQueue = locator<SyncQueueService>();
      final pendingCount = syncQueue.getPendingItems().length;
      _ref.read(appStateProvider.notifier).updatePendingSyncCount(pendingCount);
    } catch (e) {
      ErrorHandler.logError('Failed to process sync queue', e);
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
