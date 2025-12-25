/// Category mapping utilities for Pocketly → Klyro data migration.
///
/// Maps Pocketly category names to Klyro CategoryId enum values.
library;

/// Maps a Pocketly category name to a Klyro CategoryId string.
///
/// Category mapping per implementation plan:
/// - Food → food
/// - Transportation → transport
/// - Healthcare → health
/// - Shopping → shopping
/// - Bills → bills
/// - Entertainment → general (no direct match)
/// - Others → general
/// - Custom categories → general
String mapCategoryToKlyro(String? categoryName) {
  if (categoryName == null) return 'general';

  final normalizedName = categoryName.toLowerCase().trim();

  return switch (normalizedName) {
    'food' => 'food',
    'transportation' => 'transport',
    'healthcare' => 'health',
    'shopping' => 'shopping',
    'bills' => 'bills',
    'entertainment' => 'general',
    'others' => 'general',
    _ => 'general', // Custom categories default to general
  };
}

/// Checks if a category name maps directly to a Klyro category (not 'general').
///
/// Returns true for categories that have a 1:1 mapping, false for categories
/// that map to 'general' (which should have the original name appended to note).
bool isDirectlyMappedCategory(String categoryName) {
  final directlyMapped = {
    'food',
    'transportation',
    'healthcare',
    'shopping',
    'bills',
  };
  return directlyMapped.contains(categoryName.toLowerCase().trim());
}

/// Builds the note field for a Klyro transaction.
///
/// If the category is unmapped (maps to 'general'), appends the original
/// category name in brackets for reference.
///
/// Examples:
/// - "Lunch at Shoprite" with category "Food" → "Lunch at Shoprite"
/// - "Netflix" with category "Entertainment" → "Netflix [Entertainment]"
String buildKlyroNote(String expenseName, String? categoryName) {
  if (categoryName == null) return expenseName;
  if (isDirectlyMappedCategory(categoryName)) return expenseName;
  return '$expenseName [$categoryName]';
}
