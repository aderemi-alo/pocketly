import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode { light, dark, system }

class ThemeService {
  final SharedPreferences _prefs;
  static const _themeKey = 'app_theme_mode';

  ThemeService(this._prefs);

  ThemeMode getThemeMode() {
    final themeString = _prefs.getString(_themeKey);
    return _parseThemeMode(themeString);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}
