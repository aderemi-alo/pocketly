import 'package:drift/drift.dart';
import 'package:pocketly_api/database/database.dart';

/// Repository for user-related operations
class UserRepository {
  /// Creates an instance of [UserRepository]
  const UserRepository(this._db);

  final PocketlyDatabase _db;

  /// Creates a new user
  Future<User> createUser({
    required String name,
    required String email,
    required String passwordHash,
  }) async {
    final now = DateTime.now();

    final companion = UsersCompanion.insert(
      name: name,
      email: email,
      passwordHash: passwordHash,
      createdAt: now,
      updatedAt: now,
    );

    await _db.into(_db.users).insert(companion);

    // Fetch and return the newly created user
    return (_db.select(_db.users)..where((u) => u.email.equals(email)))
        .getSingle();
  }

  /// Finds a user by ID
  Future<User?> findById(String userId) async {
    return (_db.select(_db.users)..where((u) => u.id.equals(userId)))
        .getSingleOrNull();
  }

  /// Finds a user by email
  Future<User?> findByEmail(String email) async {
    return (_db.select(_db.users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  /// Updates a user's information
  Future<bool> updateUser({
    required String userId,
    String? name,
    String? email,
    String? passwordHash,
  }) async {
    final updateCompanion = UsersCompanion(
      id: Value(userId),
      name: name != null ? Value(name) : const Value.absent(),
      email: email != null ? Value(email) : const Value.absent(),
      passwordHash:
          passwordHash != null ? Value(passwordHash) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    final updatedCount = await (_db.update(_db.users)
          ..where((u) => u.id.equals(userId)))
        .write(updateCompanion);

    return updatedCount > 0;
  }

  /// Deletes a user by ID
  /// Cascade deletion will handle related data
  Future<bool> deleteUser(String userId) async {
    final deletedCount =
        await (_db.delete(_db.users)..where((u) => u.id.equals(userId))).go();

    return deletedCount > 0;
  }

  /// Checks if a user with the given email exists
  Future<bool> emailExists(String email) async {
    final user = await findByEmail(email);
    return user != null;
  }

  /// Gets all users (for admin purposes, if needed)
  Future<List<User>> getAllUsers() async {
    return _db.select(_db.users).get();
  }
}
