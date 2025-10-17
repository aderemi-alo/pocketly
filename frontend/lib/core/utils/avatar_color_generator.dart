import 'package:flutter/material.dart';
import 'package:pocketly/core/theme/app_colors.dart';

class AvatarColorGenerator {
  /// Generates a consistent gradient based on the user's name
  /// Uses the first letter to pick two bright colors from the app's color palette
  static LinearGradient generate(String name) {
    if (name.isEmpty) {
      // Default gradient if name is empty
      return const LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
      );
    }

    // Create a list of bright colors from the app's palette
    final brightColors = [
      AppColors.primary, // Vibrant Purple
      AppColors.secondary, // Teal
      AppColors.categoryFood, // Coral Red
      AppColors.categoryTransportation, // Turquoise
      AppColors.categoryEntertainment, // Mint Green
      AppColors.categoryShopping, // Pink
      AppColors.categoryHealthcare, // Seafoam
      AppColors.primaryVariant, // Deep Purple
      AppColors.secondaryVariant, // Dark Teal
      AppColors.warning, // Orange
    ];

    // Use the hash of the name to get consistent colors
    final hash = name.hashCode.abs();
    final colorIndex1 = hash % brightColors.length;
    final colorIndex2 = (hash + 1) % brightColors.length;

    debugPrint('colorIndex1: $colorIndex1');
    debugPrint('colorIndex2: $colorIndex2');

    return LinearGradient(
      colors: [brightColors[colorIndex1], brightColors[colorIndex2]],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
