import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Extension on BuildContext to provide responsive layout utilities
extension ResponsiveLayout on BuildContext {
  /// Get the current screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get the current screen width
  double get screenWidth => screenSize.width;

  /// Get the current screen height
  double get screenHeight => screenSize.height;

  /// Check if the current screen is considered mobile
  bool get isMobile => screenWidth < ResponsiveBreakpoints.tablet;

  /// Check if the current screen is considered tablet
  bool get isTablet =>
      screenWidth >= ResponsiveBreakpoints.tablet &&
      screenWidth < ResponsiveBreakpoints.desktop;

  /// Check if the current screen is considered desktop
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.desktop;

  /// Get responsive spacing for height based on screen size
  SizedBox screenHeightSpace(double percent) =>
      SizedBox(height: percent * screenHeight);

  /// Get responsive spacing for width based on screen size
  SizedBox screenWidthSpace(double percent) =>
      SizedBox(width: percent * screenWidth);

  /// Get responsive text size with proper scaling
  double sp(double value) {
    final scale = screenWidth / ResponsiveBreakpoints.baseWidth;
    final adjustedScale = scale < 1 ? scale + 0.05 : scale;
    return adjustedScale * MediaQuery.of(this).textScaler.scale(value);
  }

  /// Get responsive vertical spacing
  SizedBox verticalSpace(double value) {
    return screenWidth > ResponsiveBreakpoints.tablet
        ? SizedBox(height: value)
        : SizedBox(
            height: ((screenHeight / ResponsiveBreakpoints.baseHeight) * value)
                .toDouble(),
          );
  }

  /// Get responsive horizontal spacing
  SizedBox horizontalSpace(double value) {
    return screenWidth > ResponsiveBreakpoints.tablet
        ? SizedBox(width: value)
        : SizedBox(
            width: ((screenWidth / ResponsiveBreakpoints.baseWidth) * value)
                .toDouble(),
          );
  }

  /// Get responsive height value
  double h(double value) {
    return screenWidth > ResponsiveBreakpoints.tablet
        ? value
        : ((screenHeight / ResponsiveBreakpoints.baseHeight) * value)
              .toDouble();
  }

  /// Get responsive width value
  double w(double value) {
    return screenWidth > ResponsiveBreakpoints.tablet
        ? value
        : ((screenWidth / ResponsiveBreakpoints.baseWidth) * value).toDouble();
  }

  /// Get the minimum of width and height scaled values
  double min(double value) => math.min(w(value), h(value));

  /// Get the maximum of width and height scaled values
  double max(double value) => math.max(w(value), h(value));

  /// Get responsive padding from EdgeInsets
  EdgeInsets pad(EdgeInsets value) {
    return EdgeInsets.fromLTRB(
      w(value.left),
      h(value.top),
      w(value.right),
      h(value.bottom),
    );
  }

  /// Get responsive all-around padding
  EdgeInsets all(double value) {
    final scaled = min(value);
    return EdgeInsets.all(scaled);
  }

  /// Get responsive symmetric padding
  EdgeInsets symmetric({double vertical = 0, double horizontal = 0}) {
    return EdgeInsets.symmetric(
      vertical: h(vertical),
      horizontal: w(horizontal),
    );
  }

  EdgeInsets screenPadding() {
    return EdgeInsets.symmetric(horizontal: w(24), vertical: h(20));
  }

  /// Get responsive padding with specific sides
  EdgeInsets only({
    double top = 0,
    double left = 0,
    double bottom = 0,
    double right = 0,
  }) {
    return EdgeInsets.only(
      top: h(top),
      left: w(left),
      right: w(right),
      bottom: h(bottom),
    );
  }

  /// Get responsive padding from LTRB values
  EdgeInsets fromLTRB(double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(w(left), h(top), w(right), h(bottom));
  }

  /// Get responsive border radius
  BorderRadius radius(double value) {
    final scaled = min(value);
    return BorderRadius.circular(scaled);
  }

  /// Get responsive circular border radius
  BorderRadius circularRadius(double value) {
    final scaled = min(value);
    return BorderRadius.circular(scaled);
  }

  /// Get responsive border radius for specific corners
  BorderRadius onlyRadius({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(min(topLeft)),
      topRight: Radius.circular(min(topRight)),
      bottomLeft: Radius.circular(min(bottomLeft)),
      bottomRight: Radius.circular(min(bottomRight)),
    );
  }

  /// Get responsive font size based on screen type
  double responsiveFontSize({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive spacing based on screen type
  double responsiveSpacing({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

/// Configuration class for responsive breakpoints and base dimensions
class ResponsiveBreakpoints {
  /// Tablet breakpoint (640px)
  static const double tablet = 640.0;

  /// Desktop breakpoint (1024px)
  static const double desktop = 1024.0;

  /// Base width for mobile design (390px - iPhone 12/13/14 standard)
  static const double baseWidth = 390.0;

  /// Base height for mobile design (844px - iPhone 12/13/14 standard)
  static const double baseHeight = 844.0;

  /// Maximum content width for desktop layouts
  static const double maxContentWidth = 1200.0;

  /// Sidebar width for desktop layouts
  static const double sidebarWidth = 280.0;
}

/// Responsive layout utilities for common UI patterns
class ResponsiveLayoutUtils {
  /// Get the number of columns for a grid based on screen size
  static int getGridColumns(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    if (context.isDesktop) return desktopColumns;
    if (context.isTablet) return tabletColumns;
    return mobileColumns;
  }

  /// Get responsive card width
  static double getCardWidth(
    BuildContext context, {
    double mobileWidth = 0.9,
    double tabletWidth = 0.45,
    double desktopWidth = 0.3,
  }) {
    if (context.isDesktop) return context.screenWidth * desktopWidth;
    if (context.isTablet) return context.screenWidth * tabletWidth;
    return context.screenWidth * mobileWidth;
  }

  /// Get responsive container constraints
  static BoxConstraints getContainerConstraints(BuildContext context) {
    if (context.isDesktop) {
      return BoxConstraints(
        maxWidth: ResponsiveBreakpoints.maxContentWidth,
        minHeight: context.screenHeight * 0.8,
      );
    }
    return BoxConstraints(
      maxWidth: context.screenWidth,
      minHeight: context.screenHeight,
    );
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    return context.isDesktop ? 80.0 : 56.0;
  }

  /// Get responsive bottom navigation height
  static double getBottomNavHeight(BuildContext context) {
    return context.isDesktop ? 0.0 : 80.0;
  }
}
