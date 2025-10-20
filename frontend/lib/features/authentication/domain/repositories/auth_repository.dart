import 'package:pocketly/core/models/auth_response.dart';
import 'package:pocketly/features/authentication/domain/entities/entities.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(LoginRequest request);
  Future<void> logout();
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> updatePassword(String currentPassword, String newPassword);
}
