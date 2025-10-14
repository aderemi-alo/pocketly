import 'package:flutter/foundation.dart';

class Settings {
  // Use localhost for debug, production URL for release
  static const String baseUrl = kDebugMode
      ? 'http://localhost:8080'
      : 'https://your-production-api.com';
}
