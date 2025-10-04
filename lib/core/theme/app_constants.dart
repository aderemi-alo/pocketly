import 'package:flutter/material.dart';

class AppConstants {
  // Spacing
  static const double screenPadding = 16.0;
  static const double cardSpacing = 12.0;
  static const double sectionSpacing = 24.0;
  static const double elementSpacing = 8.0;

  // Border Radius
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 20.0;
  static const double bottomSheetRadius = 24.0;
  static const double inputRadius = 12.0;

  // Elevation/Shadows
  static const double cardElevation = 2.0;
  static const double fabElevation = 4.0;
  static const double bottomSheetElevation = 8.0;

  // Interactive Elements
  static const double fabSize = 56.0;
  static const double buttonHeight = 48.0;
  static const double touchTargetSize = 48.0;
  static const double listItemHeight = 72.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Button Press Scale
  static const double buttonPressScale = 0.96;

  // Shadow Colors
  static Color get cardShadow => Colors.black.withValues(alpha: 0.08);
  static Color get fabShadow => const Color(0xFF6C63FF).withValues(alpha: 0.3);
  static Color get bottomSheetShadow => Colors.black.withValues(alpha: 0.12);

  // Responsive Breakpoints
  static const double mobileBreakpoint = 640.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1200.0;

  // Base Dimensions for Responsive Scaling
  static const double baseWidth = 390.0;
  static const double baseHeight = 844.0;

  // Responsive Spacing Multipliers
  static const double mobileSpacingMultiplier = 1.0;
  static const double tabletSpacingMultiplier = 1.2;
  static const double desktopSpacingMultiplier = 1.5;
}
