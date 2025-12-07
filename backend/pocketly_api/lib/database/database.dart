import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:pocketly_api/utils/utils.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

const _uuid = Uuid();

/// Defines the 'users' table.
class Users extends Table {
  /// The ID of the user.
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  /// The name of the user.
  TextColumn get name => text()();

  /// The email of the user.
  TextColumn get email => text().unique()();

  /// The password hash of the user.
  TextColumn get passwordHash => text()();

  /// Whether the user's email is verified.
  BoolColumn get isEmailVerified =>
      boolean().withDefault(const Constant(false))();

  /// The date and time the user was created.
  DateTimeColumn get createdAt => dateTime()();

  /// The date and time the user was updated.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Defines the 'refresh_tokens' table.
class RefreshTokens extends Table {
  /// The ID of the refresh token.
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  /// The user the refresh token belongs to..
  TextColumn get userId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();

  /// The hash of the refresh token.
  TextColumn get tokenHash => text().unique()();

  /// The device ID of the refresh token.
  TextColumn get deviceId => text()();

  /// The date and time the refresh token was created.
  DateTimeColumn get expiresAt => dateTime().withDefault(currentDateAndTime)();

  /// The date and time the refresh token was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Defines the 'otps' table.
class Otps extends Table {
  /// The ID of the OTP.
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  /// The email the OTP is sent to.
  TextColumn get email => text()();

  /// The hashed OTP code.
  TextColumn get otpCodeHash => text()();

  /// The purpose of the OTP (email_verification or password_reset).
  TextColumn get purpose => text()();

  /// The date and time the OTP expires.
  DateTimeColumn get expiresAt => dateTime()();

  /// Whether the OTP has been used.
  BoolColumn get isUsed => boolean().withDefault(const Constant(false))();

  /// The number of verification attempts.
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();

  /// The date and time the OTP was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Defines the 'categories' table.
class Categories extends Table {
  /// The ID of the category.
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  /// The name of the category.
  TextColumn get name => text()();

  /// The icon of the category.
  TextColumn get icon => text()();

  /// The color of the category.
  TextColumn get color => text()();

  /// NULL = predefined category, NOT NULL = user's custom category
  TextColumn get userId =>
      text().nullable().references(Users, #id, onDelete: KeyAction.cascade)();

  /// The date and time the category was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// The date and time the category was updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Whether the category is deleted (soft delete).
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Defines the 'expenses' table.
class Expenses extends Table {
  /// The ID of the expense.
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  /// The user the expense belongs to.
  TextColumn get userId =>
      text().nullable().references(Users, #id, onDelete: KeyAction.cascade)();

  /// The name of the expense.
  TextColumn get name => text()();

  /// The description of the expense. Nullable.
  TextColumn get description => text().nullable()();

  /// The amount of the expense.
  RealColumn get amount => real()();

  /// The date of the expense.
  DateTimeColumn get date => dateTime()();

  /// The category of the expense.
  TextColumn get categoryId => text()
      .nullable()
      .references(Categories, #id, onDelete: KeyAction.restrict)();

  /// The currency code (ISO 4217). Defaults to NGN.
  TextColumn get currency => text().withDefault(const Constant('NGN'))();

  /// The date and time the expense was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// The date and time the expense was updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Whether the expense is deleted (soft delete).
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Expenses, Users, Categories, RefreshTokens, Otps])

/// The database for the Pocketly app.
class PocketlyDatabase extends _$PocketlyDatabase {
  /// The constructor for the Pocketly database.
  PocketlyDatabase() : super(_openConnection()) {
    _initializeDatabase();
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 3) {
          // Add isDeleted column to expenses table
          // Using custom SQL since addColumn has type issues with boolean columns
          await customStatement(
            'ALTER TABLE expenses ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0;',
          );
          // Add isDeleted column to categories table
          await customStatement(
            'ALTER TABLE categories ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0;',
          );
        }
        if (from < 4) {
          // Add currency column to expenses table with default 'NGN'
          await customStatement(
            "ALTER TABLE expenses ADD COLUMN currency TEXT NOT NULL DEFAULT 'NGN';",
          );
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return NativeDatabase.opened(sqlite3.open(Settings.dbName));
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
