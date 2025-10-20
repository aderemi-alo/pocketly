import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppInfoService {
  static const platform = MethodChannel('com.example.app/appinfo');

  static Future<String> getVersion() async {
    if (kIsWeb) {
      return 'Web Version';
    }

    try {
      final String version = await platform.invokeMethod('getVersion');
      return version;
    } catch (e) {
      return 'Unknown';
    }
  }

  static Future<String> getBuildNumber() async {
    if (kIsWeb) {
      return '1';
    }

    try {
      final String buildNumber = await platform.invokeMethod('getBuildNumber');
      return buildNumber;
    } catch (e) {
      return 'Unknown';
    }
  }

  static Future<String> getVersionWithBuild() async {
    final version = await getVersion();
    final buildNumber = await getBuildNumber();
    return '$version ($buildNumber)';
  }
}
