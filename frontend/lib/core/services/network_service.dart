import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((results) {
      // Handle both single result and list of results for compatibility
      if (results is List<ConnectivityResult>) {
        final resultsList = results as List<ConnectivityResult>;
        return resultsList.any((result) => result != ConnectivityResult.none);
      }
      // For older versions that return single result
      final singleResult = results as ConnectivityResult;
      return singleResult != ConnectivityResult.none;
    });
  }

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    // Handle both single result and list of results for compatibility
    if (result is List<ConnectivityResult>) {
      final resultsList = result as List<ConnectivityResult>;
      return resultsList.any((r) => r != ConnectivityResult.none);
    }
    // For older versions that return single result
    final singleResult = result as ConnectivityResult;
    return singleResult != ConnectivityResult.none;
  }

  Future<bool> hasInternetAccess() async {
    final isConnected = await this.isConnected;
    if (!isConnected) return false;

    // Ping a server to verify actual internet access
    try {
      final dio = Dio();
      await dio.get(
        'https://www.google.com',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Internet access check failed: $e');
      return false;
    }
  }
}

final networkServiceProvider = Provider((ref) => NetworkService());

final connectivityProvider = StreamProvider<bool>((ref) {
  final networkService = ref.read(networkServiceProvider);
  return networkService.connectivityStream;
});
