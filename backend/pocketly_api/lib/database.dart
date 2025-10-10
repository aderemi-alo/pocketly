import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
part 'database.g.dart';

/// Defines the 'users' table.
class Users extends Table {
  /// The ID of the user.
  IntColumn get id => integer().autoIncrement()();

  /// The name of the user.
  TextColumn get name => text().unique()();

  /// The email of the user.
  TextColumn get email => text()();

  /// The password hash of the user.
  TextColumn get passwordHash => text()();

  /// The date and time the user was created.
  DateTimeColumn get createdAt => dateTime()();

  /// The date and time the user was updated.
  DateTimeColumn get updatedAt => dateTime()();
}

/// Defines the 'categories' table.
class Categories extends Table {
  /// The ID of the category.
  IntColumn get id => integer().autoIncrement()();

  /// The name of the category.
  TextColumn get name => text()();

  /// The icon of the category.
  TextColumn get icon => text()();

  /// The color of the category.
  TextColumn get color => text()();

  /// NULL = predefined category, NOT NULL = user's custom category
  IntColumn get userId => integer()
      .nullable()
      .references(Users, #id, onDelete: KeyAction.cascade)();

  /// The date and time the category was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// The date and time the category was updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Defines the 'expenses' table.
class Expenses extends Table {
  /// The ID of the expense.
  IntColumn get id => integer().autoIncrement()();

  /// The user the expense belongs to.
  IntColumn get userId => integer()
      .nullable()
      .references(Users, #id, onDelete: KeyAction.cascade)();

  /// The name of the expense.
  TextColumn get name => text()();

  /// The description of the expense. Nullable.
  TextColumn get description => text().nullable()();

  /// The amount of the expense.
  RealColumn get amount => real()();

  /// The date of the expense.
  DateTimeColumn get date => dateTime()();

  /// The category of the expense.
  IntColumn get categoryId => integer()
      .nullable()
      .references(Categories, #id, onDelete: KeyAction.restrict)();

  /// The date and time the expense was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// The date and time the expense was updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Expenses, Users, Categories])

/// The database for the Pocketly app.
class PocketlyDatabase extends _$PocketlyDatabase {
  /// The constructor for the Pocketly database.
  PocketlyDatabase() : super(_openConnection()) {
    _initializeDatabase();
  }

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return NativeDatabase.opened(sqlite3.open('gray-horst.db'));
  }

  /// Initializes the database with predefined categories if they don't exist
  Future<void> _initializeDatabase() async {
    // Check if predefined categories already exist
    final predefinedCategories =
        await (select(categories)..where((c) => c.userId.isNull())).get();

    // If no predefined categories exist, seed them
    if (predefinedCategories.isEmpty) {
      await _seedPredefinedCategories();
    }
  }

  /// Seeds the database with predefined categories
  Future<void> _seedPredefinedCategories() async {
    final predefinedCategories = [
      {
        'name': 'Food',
        'icon': 'utensils',
        'color': '#4CAF50',
      },
      {
        'name': 'Transportation',
        'icon': 'car',
        'color': '#2196F3',
      },
      {
        'name': 'Entertainment',
        'icon': 'tv',
        'color': '#9C27B0',
      },
      {
        'name': 'Shopping',
        'icon': 'shoppingCart',
        'color': '#FF9800',
      },
      {
        'name': 'Bills',
        'icon': 'fileText',
        'color': '#FF5722',
      },
      {
        'name': 'Healthcare',
        'icon': 'heart',
        'color': '#E91E63',
      },
      {
        'name': 'Others',
        'icon': 'menu',
        'color': '#607D8B',
      },
    ];

    for (final categoryData in predefinedCategories) {
      await into(categories).insert(
        CategoriesCompanion.insert(
          name: categoryData['name']!,
          icon: categoryData['icon']!,
          color: categoryData['color']!,
        ),
      );
    }
  }
}
