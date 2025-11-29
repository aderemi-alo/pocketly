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
      throw AppException(ErrorHandler.getErrorMessage(e));
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
      throw AppException(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _apiClient.dio.put(
        '/auth/user',
        data: request.toJson(),
      );

      // Backend wraps response in 'data' field
      final user = UserModel.fromJson(response.data['data']);

      // Update stored user data
      await _tokenStorage.saveUserData(user);

      return user;
    } catch (e) {
      throw AppException(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<UserModel> fetchUserProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/user');

      // Backend wraps response in 'data' field
      final user = UserModel.fromJson(response.data['data']);

      // Update stored user data
      await _tokenStorage.saveUserData(user);

      return user;
    } catch (e) {
      throw AppException(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      final deviceId = await locator<DeviceIdService>().getDeviceId();
      final response = await _apiClient.dio.post(
        '/auth/logout',
        data: {'deviceId': deviceId},
      );
      if (response.statusCode != 200) {
        AppLogger.warning('Logout API call failed', response.data);
        throw AppException('Logout failed: ${response.statusCode}');
      }
    } catch (e) {
      // Continue with logout even if API call fails
      AppLogger.warning('Logout API call failed', e);
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
          'rotateToken': true,
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
      throw AppException(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _apiClient.dio.post(
        '/auth/update-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } catch (e) {
      throw AppException(ErrorHandler.getErrorMessage(e));
    }
  }

  @override
  Future<void> deleteAccount(String? password) async {
    try {
      await _apiClient.dio.delete(
        '/auth/delete',
        data: password != null ? {'password': password} : null,
      );
    } catch (e) {
      throw AppException(ErrorHandler.getErrorMessage(e));
    }
  }
}
