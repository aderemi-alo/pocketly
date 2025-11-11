import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketly/core/services/device_id_service.dart';
import 'package:pocketly/core/services/token_storage_service.dart';
import 'package:pocketly/core/services/logger_service.dart';
import 'package:pocketly/core/utils/error_handler.dart';
import 'package:pocketly/core/utils/settings.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorageService _tokenStorage;
  final DeviceIdService _deviceIdService;

  bool _isRefreshing = false;
  final List<Completer<String?>> _tokenRefreshCompleters = [];

  ApiClient(this._tokenStorage, this._deviceIdService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Settings.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip auth header for auth endpoints
          if (options.path.contains('/auth/')) {
            return handler.next(options);
          }

          final token = await _tokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          AppLogger.debug('📤 Request: ${options.method} ${options.path}');
          return handler.next(options);
        },

        onResponse: (response, handler) {
          AppLogger.debug(
            '📥 Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },

        onError: (error, handler) async {
          ErrorHandler.logError(
            'API Error: ${error.requestOptions.path}',
            error,
          );

          // Handle 401 - Unauthorized (token expired)
          if (error.response?.statusCode == 401) {
            // Don't retry if already on auth endpoint
            if (error.requestOptions.path.contains('/auth/')) {
              return handler.next(error);
            }

            // Try to refresh token
            final newToken = await _refreshToken();
            if (newToken != null) {
              // Retry the failed request with new token
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer $newToken';

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              // Refresh failed, clear tokens and redirect to login
              await _tokenStorage.clearTokens();
              return handler.next(error);
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  Future<String?> _refreshToken() async {
    // Prevent multiple simultaneous refresh attempts
    if (_isRefreshing) {
      // Wait for ongoing refresh
      final completer = Completer<String?>();
      _tokenRefreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      final deviceId = await _deviceIdService.getDeviceId();

      if (refreshToken == null) {
        AppLogger.warning('❌ No refresh token available');
        return null;
      }

      AppLogger.info('🔄 Refreshing access token...');

      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
          'deviceId': deviceId,
          'rotateToken': false,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final newAccessToken = data['accessToken'] as String;
        final userId = data['user']['id'] as String;

        // Save new access token (refresh token stays the same if rotateToken=false)
        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: refreshToken,
          userId: userId,
        );

        AppLogger.info('✅ Token refreshed successfully');

        // Notify all waiting completers
        for (final completer in _tokenRefreshCompleters) {
          completer.complete(newAccessToken);
        }
        _tokenRefreshCompleters.clear();

        return newAccessToken;
      }

      return null;
    } catch (e) {
      ErrorHandler.logError('Token refresh failed', e);

      // Notify all waiting completers of failure
      for (final completer in _tokenRefreshCompleters) {
        completer.complete(null);
      }
      _tokenRefreshCompleters.clear();

      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  Dio get dio => _dio;
}
