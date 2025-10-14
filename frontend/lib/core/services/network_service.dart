import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> hasInternetAccess() async {
    final isConnected = await this.isConnected;
    if (!isConnected) return false;

    // Optional: Ping a server to verify actual internet access
    try {
      // You can implement actual ping logic here
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
