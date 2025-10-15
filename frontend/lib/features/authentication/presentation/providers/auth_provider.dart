import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/authentication/domain/domain.dart';
import 'package:pocketly/features/authentication/data/data.dart';

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

  AuthNotifier(this._authRepository, this._tokenStorage)
    : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final hasTokens = await _tokenStorage.hasValidTokens();
    if (!hasTokens) {
      return;
    }

    // Check if access token is expired
    final isExpired = await _tokenStorage.isAccessTokenExpired();

    if (isExpired) {
      // Try to refresh the token
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          await _authRepository.refreshToken(refreshToken);
          // If refresh succeeds, user is authenticated
          state = state.copyWith(isAuthenticated: true);
        } catch (e) {
          // Refresh failed, clear tokens and remain unauthenticated
          debugPrint('Token refresh failed on startup: $e');
          await _tokenStorage.clearTokens();
          state = state.copyWith(isAuthenticated: false);
        }
      } else {
        // No refresh token, clear everything
        await _tokenStorage.clearTokens();
        state = state.copyWith(isAuthenticated: false);
      }
    } else {
      // Token is still valid
      state = state.copyWith(isAuthenticated: true);
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

      state = state.copyWith(
        isLoading: false,
        user: response.user,
        isAuthenticated: true,
      );
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

      state = state.copyWith(
        isLoading: false,
        user: response.user,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.logout();
      state = const AuthState();
    } catch (e) {
      // Clear state even if logout fails
      state = const AuthState();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    locator<TokenStorageService>(),
  );
});
