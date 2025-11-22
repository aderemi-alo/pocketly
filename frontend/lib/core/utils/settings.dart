import 'dart:io';
import 'package:flutter/foundation.dart';

class Settings {
  // Use appropriate host for debug mode:
  // - Android: 10.0.2.2 (maps to host machine's localhost)
  // - iOS/Web: localhost
  // For physical Android devices, use your computer's IP address instead
  static String get baseUrl {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        // Android emulator uses 10.0.2.2 to reach host machine
        // For physical device, replace with your computer's IP (e.g., 'http://192.168.1.100:8080')
        return 'http://10.0.2.2:8080';
      } else {
        // iOS simulator and web can use localhost
        return 'http://localhost:8080';
      }
    }
    return 'https://pocketly-e999.globeapp.dev';
  }
}
