import 'package:pocketly/core/core.dart';

class AppTextTheme {
  static const String _fontFamily = 'Roboto';

  // LIGHT MODE TEXT THEME
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: _displayLarge(AppColors.textPrimary),
    displayMedium: _displayMedium(AppColors.textPrimary),
    displaySmall: _displaySmall(AppColors.textPrimary),
    headlineLarge: _headlineLarge(AppColors.textPrimary),
    headlineMedium: _headlineMedium(AppColors.textPrimary),
    headlineSmall: _headlineSmall(AppColors.textPrimary),
    titleLarge: _titleLarge(AppColors.textPrimary),
    titleMedium: _titleMedium(AppColors.textPrimary),
    titleSmall: _titleSmall(AppColors.textPrimary),
    bodyLarge: _bodyLarge(AppColors.textPrimary),
    bodyMedium: _bodyMedium(AppColors.textPrimary),
    bodySmall: _bodySmall(AppColors.textPrimary),
    labelLarge: _labelLarge(AppColors.textTertiary),
    labelMedium: _labelMedium(AppColors.textTertiary),
    labelSmall: _labelSmall(AppColors.textTertiary),
  );

  // DARK MODE TEXT THEME
  static TextTheme get darkTextTheme => TextTheme(
    displayLarge: _displayLarge(AppColorsDark.textPrimary),
    displayMedium: _displayMedium(AppColorsDark.textPrimary),
    displaySmall: _displaySmall(AppColorsDark.textPrimary),
    headlineLarge: _headlineLarge(AppColorsDark.textPrimary),
    headlineMedium: _headlineMedium(AppColorsDark.textPrimary),
    headlineSmall: _headlineSmall(AppColorsDark.textPrimary),
    titleLarge: _titleLarge(AppColorsDark.textPrimary),
    titleMedium: _titleMedium(AppColorsDark.textPrimary),
    titleSmall: _titleSmall(AppColorsDark.textPrimary),
    bodyLarge: _bodyLarge(AppColorsDark.textPrimary),
    bodyMedium: _bodyMedium(AppColorsDark.textPrimary),
    bodySmall: _bodySmall(AppColorsDark.textPrimary),
    labelLarge: _labelLarge(AppColorsDark.textTertiary),
    labelMedium: _labelMedium(AppColorsDark.textTertiary),
    labelSmall: _labelSmall(AppColorsDark.textTertiary),
  );

  // DEPRECATED: Use lightTextTheme instead
  @Deprecated('Use lightTextTheme instead')
  static TextTheme get textTheme => lightTextTheme;

  // Private style builders
  static TextStyle _displayLarge(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.1,
  );

  static TextStyle _displayMedium(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.1,
  );

  static TextStyle _displaySmall(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.1,
  );

  static TextStyle _headlineLarge(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.2,
  );

  static TextStyle _headlineMedium(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.2,
  );

  static TextStyle _headlineSmall(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: color,
    height: 1.2,
  );

  static TextStyle _titleLarge(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.3,
  );

  static TextStyle _titleMedium(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.3,
  );

  static TextStyle _titleSmall(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.3,
  );

  static TextStyle _bodyLarge(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.5,
  );

  static TextStyle _bodyMedium(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.5,
  );

  static TextStyle _bodySmall(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.4,
  );

  static TextStyle _labelLarge(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.4,
  );

  static TextStyle _labelMedium(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.4,
  );

  static TextStyle _labelSmall(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.3,
  );
}
