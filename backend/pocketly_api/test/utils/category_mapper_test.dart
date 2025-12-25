import 'package:pocketly_api/utils/category_mapper.dart';
import 'package:test/test.dart';

void main() {
  group('mapCategoryToKlyro', () {
    test('maps Food to food', () {
      expect(mapCategoryToKlyro('Food'), equals('food'));
    });

    test('maps Transportation to transport', () {
      expect(mapCategoryToKlyro('Transportation'), equals('transport'));
    });

    test('maps Healthcare to health', () {
      expect(mapCategoryToKlyro('Healthcare'), equals('health'));
    });

    test('maps Shopping to shopping', () {
      expect(mapCategoryToKlyro('Shopping'), equals('shopping'));
    });

    test('maps Bills to bills', () {
      expect(mapCategoryToKlyro('Bills'), equals('bills'));
    });

    test('maps Entertainment to general', () {
      expect(mapCategoryToKlyro('Entertainment'), equals('general'));
    });

    test('maps Others to general', () {
      expect(mapCategoryToKlyro('Others'), equals('general'));
    });

    test('maps custom categories to general', () {
      expect(mapCategoryToKlyro('My Custom Category'), equals('general'));
      expect(mapCategoryToKlyro('Subscriptions'), equals('general'));
    });

    test('handles null input', () {
      expect(mapCategoryToKlyro(null), equals('general'));
    });

    test('is case insensitive', () {
      expect(mapCategoryToKlyro('FOOD'), equals('food'));
      expect(mapCategoryToKlyro('food'), equals('food'));
      expect(mapCategoryToKlyro('FoOd'), equals('food'));
    });

    test('trims whitespace', () {
      expect(mapCategoryToKlyro('  Food  '), equals('food'));
      expect(mapCategoryToKlyro('\tBills\n'), equals('bills'));
    });
  });

  group('isDirectlyMappedCategory', () {
    test('returns true for directly mapped categories', () {
      expect(isDirectlyMappedCategory('Food'), isTrue);
      expect(isDirectlyMappedCategory('Transportation'), isTrue);
      expect(isDirectlyMappedCategory('Healthcare'), isTrue);
      expect(isDirectlyMappedCategory('Shopping'), isTrue);
      expect(isDirectlyMappedCategory('Bills'), isTrue);
    });

    test('returns false for categories that map to general', () {
      expect(isDirectlyMappedCategory('Entertainment'), isFalse);
      expect(isDirectlyMappedCategory('Others'), isFalse);
      expect(isDirectlyMappedCategory('My Custom Category'), isFalse);
    });

    test('is case insensitive', () {
      expect(isDirectlyMappedCategory('FOOD'), isTrue);
      expect(isDirectlyMappedCategory('food'), isTrue);
      expect(isDirectlyMappedCategory('ENTERTAINMENT'), isFalse);
    });
  });

  group('buildKlyroNote', () {
    test('returns expense name for directly mapped categories', () {
      expect(buildKlyroNote('Lunch at Shoprite', 'Food'),
          equals('Lunch at Shoprite'));
      expect(
          buildKlyroNote('Uber ride', 'Transportation'), equals('Uber ride'));
    });

    test('appends category name for unmapped categories', () {
      expect(
        buildKlyroNote('Netflix subscription', 'Entertainment'),
        equals('Netflix subscription [Entertainment]'),
      );
      expect(
        buildKlyroNote('Random expense', 'Others'),
        equals('Random expense [Others]'),
      );
    });

    test('appends category name for custom categories', () {
      expect(
        buildKlyroNote('Monthly donation', 'Church'),
        equals('Monthly donation [Church]'),
      );
    });

    test('returns expense name when category is null', () {
      expect(buildKlyroNote('Some expense', null), equals('Some expense'));
    });
  });
}
