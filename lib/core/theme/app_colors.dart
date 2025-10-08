import 'package:pocketly/core/core.dart';

class AppColors {
  //Primary Colors
  static const Color primary = Color(
    0xFF6C63FF,
  ); // (Vibrant Purple) - Main brand color, CTAs, FAB

  static const Color primaryVariant = Color(
    0xFF5F52DF,
  ); // (Deep Purple) - Hover states, active elements

  static const Color primaryLight = Color(
    0xFFE8E6FF,
  ); // (Lavender) - Backgrounds, subtle highlights

  //Secondary Colors
  static const Color secondary = Color(
    0xFF00D4AA,
  ); // (Teal) - Success states, positive indicators

  static const Color secondaryVariant = Color(
    0xFF00B890,
  ); // (Dark Teal) - Accents

  static const Color secondaryLight = Color(
    0xFFE0FFF9,
  ); // (Mint) - Success backgrounds

  //Neutral Colors
  static const Color background = Color(
    0xFFF8F9FE,
  ); // Light Grayish Blue - Main app background

  static const Color surface = Color(
    0xFFFFFFFF,
  ); // White - Cards, sheets, containers

  static const Color black = Color(0xFF000000); // Black

  static const Color surfaceVariant = Color(
    0xFFF5F5F7,
  ); // Light Gray - Subtle dividers

  static const Color outline = Color(
    0xFFE0E0E8,
  ); // Border Gray - Card borders, dividers

  //Text Colors
  static const Color textPrimary = Color(
    0xFF1A1A2E,
  ); // Almost Black - Headlines, important text

  static const Color textSecondary = Color(
    0xFF6B6B80,
  ); // Medium Gray - Body text, descriptions

  static const Color textTertiary = Color(
    0xFF9999AB,
  ); // Light Gray - Hints, placeholders

  //Category Colors (for expense categories)
  static const Color categoryFood = Color(0xFFFF6B6B); // Coral Red - 🍔 Food

  static const Color categoryTransportation = Color(
    0xFF4ECDC4,
  ); // Turquoise - 🚗 Transportation

  static const Color categoryEntertainment = Color(
    0xFF95E1D3,
  ); // Mint Green - 🎬 Entertainment

  static const Color categoryShopping = Color(
    0xFFF38181,
  ); // Pink - 🛍️ Shopping

  static const Color categoryBills = Color(
    0xFFFFA07A,
  ); // Light Orange - 💡 Bills

  static const Color categoryHealthcare = Color(
    0xFF98D8C8,
  ); // Seafoam - 🏥 Healthcare

  static const Color categoryOthers = Color(0xFFB8B8B8); // Gray - 📦 Others

  //Semantic Colors
  static const Color error = Color(0xFFFF5252); // Red - Errors, delete actions
  static const Color warning = Color(0xFFFFB84D); // Orange - Warnings
  static const Color success = Color(
    0xFF00D4AA,
  ); // Teal - Success messages (same as secondary)
  static const Color info = Color(
    0xFF6C63FF,
  ); // Purple - Info messages (same as primary)
}
