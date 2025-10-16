import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/authentication/domain/domain.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  AuthRepositoryImpl(this._apiClient, this._tokenStorage);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      // Backend wraps response in 'data' field
      final authResponse = AuthResponse.fromJson(response.data['data']);

      // Store tokens
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id!,
      );

      // Store user data
      await _tokenStorage.saveUserData(authResponse.user);

      return authResponse;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponse> register(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: request.toJson(),
      );

      // Backend wraps response in 'data' field
      final authResponse = AuthResponse.fromJson(response.data['data']);

      // Store tokens
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id!,
      );
      // Store user data
      await _tokenStorage.saveUserData(authResponse.user);

      return authResponse;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
      debugPrint('Logout API call failed: $e');
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final deviceId = await locator<DeviceIdService>().getDeviceId();
      final response = await _apiClient.dio.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
          'deviceId': deviceId,
          'rotateToken': false,
        },
      );

      // Backend wraps response in 'data' field
      final authResponse = AuthResponse.fromJson(response.data['data']);

      // Store new tokens
      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
        userId: authResponse.user.id!,
      );

      return authResponse;
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }
}
