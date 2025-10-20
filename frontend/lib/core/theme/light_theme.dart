import 'package:pocketly/core/core.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: AppColors.background,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primary,

        secondary: AppColors.secondary,
        onSecondary: AppColors.surface,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondary,

        tertiary: AppColors.categoryFood,
        onTertiary: AppColors.surface,
        tertiaryContainer: AppColors.primaryLight,
        onTertiaryContainer: AppColors.primary,

        error: AppColors.error,
        errorContainer: AppColors.primaryLight,
        onErrorContainer: AppColors.error,

        onSurface: AppColors.textPrimary,
        surfaceContainer: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.outline,
        outlineVariant: AppColors.surfaceVariant,

        shadow: AppColors.textPrimary,
        scrim: AppColors.textPrimary,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.surface,
        inversePrimary: AppColors.primaryLight,
      ),

      // Text Theme
      textTheme: AppTextTheme.lightTextTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: AppTextTheme.lightTextTheme.titleLarge,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.black,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.textPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 48),
          textStyle: AppTextTheme.lightTextTheme.titleMedium,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextTheme.lightTextTheme.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 48),
          textStyle: AppTextTheme.lightTextTheme.titleMedium,
        ),
      ),

      // FAB Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: CircleBorder(),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: AppTextTheme.lightTextTheme.bodyMedium,
        hintStyle: AppTextTheme.lightTextTheme.bodyMedium?.copyWith(
          color: AppColors.textTertiary,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryLight,
        disabledColor: AppColors.surfaceVariant,
        labelStyle: AppTextTheme.lightTextTheme.bodyMedium,
        secondaryLabelStyle: AppTextTheme.lightTextTheme.bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: AppColors.outline),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 8,
        minLeadingWidth: 40,
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 24),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(color: AppColors.surface, size: 24),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.surfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.surfaceVariant;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.surface),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.outline;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceVariant,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.1),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTextTheme.lightTextTheme.bodyMedium,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceVariant,
        circularTrackColor: AppColors.surfaceVariant,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextTheme.lightTextTheme.bodyMedium?.copyWith(
          color: AppColors.surface,
        ),
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: AppTextTheme.lightTextTheme.titleLarge,
        contentTextStyle: AppTextTheme.lightTextTheme.bodyMedium,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextTheme.lightTextTheme.labelMedium,
        unselectedLabelStyle: AppTextTheme.lightTextTheme.labelMedium,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColorsDark.background,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColorsDark.primary,
        primaryContainer: AppColorsDark.primaryLight,
        onPrimaryContainer: AppColorsDark.primary,

        secondary: AppColorsDark.secondary,
        onSecondary: AppColorsDark.textPrimary,
        secondaryContainer: AppColorsDark.secondaryLight,
        onSecondaryContainer: AppColorsDark.secondary,

        tertiary: AppColorsDark.categoryFood,
        onTertiary: AppColorsDark.textPrimary,
        tertiaryContainer: AppColorsDark.primaryLight,
        onTertiaryContainer: AppColorsDark.primary,

        error: AppColorsDark.error,
        errorContainer: AppColorsDark.primaryLight,
        onErrorContainer: AppColorsDark.error,

        background: AppColorsDark.background,

        surface: AppColorsDark.surface,
        onSurface: AppColorsDark.textPrimary,
        surfaceContainer: AppColorsDark.surfaceVariant,
        onSurfaceVariant: AppColorsDark.textSecondary,
        outline: AppColorsDark.outline,
        outlineVariant: AppColorsDark.surfaceVariant,

        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColorsDark.textPrimary,
        onInverseSurface: AppColorsDark.surface,
        inversePrimary: AppColorsDark.primaryLight,
      ),

      // Text Theme
      textTheme: AppTextTheme.darkTextTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsDark.surface,
        foregroundColor: AppColorsDark.textPrimary,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: AppTextTheme.darkTextTheme.titleLarge,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColorsDark.black,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColorsDark.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.primary,
          foregroundColor: AppColorsDark.textPrimary,
          elevation: 2,
          shadowColor: AppColorsDark.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 48),
          textStyle: AppTextTheme.darkTextTheme.titleMedium,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsDark.primary,
          textStyle: AppTextTheme.darkTextTheme.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 48),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsDark.primary,
          side: const BorderSide(color: AppColorsDark.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 48),
          textStyle: AppTextTheme.darkTextTheme.titleMedium,
        ),
      ),

      // FAB Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColorsDark.primary,
        foregroundColor: AppColorsDark.textPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: CircleBorder(),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColorsDark.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColorsDark.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColorsDark.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColorsDark.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColorsDark.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: AppTextTheme.darkTextTheme.bodyMedium?.copyWith(
          color: AppColorsDark.textSecondary,
        ),
        hintStyle: AppTextTheme.darkTextTheme.bodyMedium?.copyWith(
          color: AppColorsDark.textTertiary,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsDark.surfaceVariant,
        selectedColor: AppColorsDark.primaryLight,
        disabledColor: AppColorsDark.surfaceVariant,
        labelStyle: AppTextTheme.darkTextTheme.bodyMedium,
        secondaryLabelStyle: AppTextTheme.darkTextTheme.bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: AppColorsDark.outline),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColorsDark.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 8,
        minLeadingWidth: 40,
        textColor: AppColorsDark.textPrimary,
        iconColor: AppColorsDark.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColorsDark.outline,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColorsDark.textSecondary,
        size: 24,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: AppColorsDark.textPrimary,
        size: 24,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.primary;
          }
          return AppColorsDark.surfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.primaryLight;
          }
          return AppColorsDark.surfaceVariant;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColorsDark.textPrimary),
        side: const BorderSide(color: AppColorsDark.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.primary;
          }
          return AppColorsDark.outline;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColorsDark.primary,
        inactiveTrackColor: AppColorsDark.surfaceVariant,
        thumbColor: AppColorsDark.primary,
        overlayColor: AppColorsDark.primary.withValues(alpha: 0.1),
        valueIndicatorColor: AppColorsDark.primary,
        valueIndicatorTextStyle: AppTextTheme.darkTextTheme.bodyMedium,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColorsDark.primary,
        linearTrackColor: AppColorsDark.surfaceVariant,
        circularTrackColor: AppColorsDark.surfaceVariant,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsDark.surfaceVariant,
        contentTextStyle: AppTextTheme.darkTextTheme.bodyMedium?.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        actionTextColor: AppColorsDark.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColorsDark.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: AppTextTheme.darkTextTheme.titleLarge,
        contentTextStyle: AppTextTheme.darkTextTheme.bodyMedium,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorsDark.surface,
        selectedItemColor: AppColorsDark.primary,
        unselectedItemColor: AppColorsDark.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextTheme.darkTextTheme.labelMedium,
        unselectedLabelStyle: AppTextTheme.darkTextTheme.labelMedium,
      ),
    );
  }
}
