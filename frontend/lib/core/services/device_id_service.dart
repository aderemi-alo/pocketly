import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pocketly/core/services/logger_service.dart';
import 'package:pocketly/core/services/token_storage_service.dart';
import 'dart:io';

class DeviceIdService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final TokenStorageService _tokenStorage;

  DeviceIdService(this._tokenStorage);

  Future<String> getDeviceId() async {
    // Check if we already have a stored device ID
    final storedId = await _tokenStorage.getDeviceId();
    if (storedId != null) {
      return storedId;
    }

    // Generate new device ID based on platform
    String deviceId;
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown-ios';
      } else if (kIsWeb) {
        deviceId = 'web-${DateTime.now().millisecondsSinceEpoch}';
      } else {
        deviceId = 'unknown-${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      AppLogger.error('Failed to get device ID', e);
      deviceId = 'fallback-${DateTime.now().millisecondsSinceEpoch}';
    }

    // Store for future use
    await _tokenStorage.saveDeviceId(deviceId);
    return deviceId;
  }
}
