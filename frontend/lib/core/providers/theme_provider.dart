import 'package:pocketly/core/core.dart';
import 'package:pocketly/core/services/theme_service.dart' as theme_service;

class ThemeState {
  final theme_service.ThemeMode themeMode;
  final Brightness? systemBrightness;

  const ThemeState({required this.themeMode, this.systemBrightness});

  ThemeState copyWith({
    theme_service.ThemeMode? themeMode,
    Brightness? systemBrightness,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      systemBrightness: systemBrightness ?? this.systemBrightness,
    );
  }

  Brightness get effectiveBrightness {
    if (themeMode == theme_service.ThemeMode.system) {
      return systemBrightness ?? Brightness.light;
    }
    return themeMode == theme_service.ThemeMode.dark
        ? Brightness.dark
        : Brightness.light;
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final theme_service.ThemeService _themeService;

  ThemeNotifier(this._themeService)
    : super(ThemeState(themeMode: _themeService.getThemeMode()));

  Future<void> setThemeMode(theme_service.ThemeMode mode) async {
    await _themeService.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  void updateSystemBrightness(Brightness brightness) {
    state = state.copyWith(systemBrightness: brightness);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(locator<theme_service.ThemeService>());
});
