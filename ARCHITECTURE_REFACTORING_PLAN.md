# Architecture Refactoring Plan

## Executive Summary

This document outlines all architecture violations found in the Pocketly codebase and provides a comprehensive refactoring roadmap to align with Clean Architecture principles for both backend (Dart Frog) and frontend (Flutter).

### Current State
- **Backend**: Flat structure with business logic in routes, repositories directly accessing database
- **Frontend**: Missing use cases layer, domain layer violations, repositories in wrong location

### Target Architecture
- **Backend**: Feature-based layered architecture (Routes → Handlers → Use Cases → Repositories → Datasources)
- **Frontend**: Clean Architecture with proper separation (Providers → Use Cases → Repositories → Datasources)

### Scope
- **Backend**: 3 features (auth, expenses, categories) need restructuring
- **Frontend**: 3 features (authentication, expenses, settings) need restructuring
- **Estimated Effort**: High (affects entire codebase)
- **Risk Level**: High (breaking changes across all layers)

---

## Backend Architecture Issues

### 1. Missing Feature-Based Structure

**Priority**: HIGH

**Current Structure**:
```
backend/pocketly_api/lib/
├── repositories/
│   ├── auth/
│   ├── expense/
│   └── category/
├── models/
└── utils/
```

**Expected Structure**:
```
backend/pocketly_api/lib/
└── features/
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── expenses/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── categories/
        ├── data/
        ├── domain/
        └── presentation/
```

**Affected Files**:
- `lib/repositories/auth/auth_repository.dart` → Should be `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/repositories/auth/user_repository.dart` → Should be `lib/features/auth/data/repositories/user_repository_impl.dart`
- `lib/repositories/auth/otp_repository.dart` → Should be `lib/features/auth/data/repositories/otp_repository_impl.dart`
- `lib/repositories/expense/expense_repository.dart` → Should be `lib/features/expenses/data/repositories/expense_repository_impl.dart`
- `lib/repositories/expense/expense_query_repository.dart` → Should be `lib/features/expenses/data/repositories/expense_query_repository_impl.dart`
- `lib/repositories/expense/expense_analytics_repository.dart` → Should be `lib/features/expenses/data/repositories/expense_analytics_repository_impl.dart`
- `lib/repositories/category/category_repository.dart` → Should be `lib/features/categories/data/repositories/category_repository_impl.dart`
- `lib/models/user_response.dart` → Should be `lib/features/auth/presentation/dto/user_response_dto.dart`
- `lib/models/auth_response.dart` → Should be `lib/features/auth/presentation/dto/auth_response_dto.dart`
- `lib/models/expense_response.dart` → Should be `lib/features/expenses/presentation/dto/expense_response_dto.dart`
- `lib/models/category_response.dart` → Should be `lib/features/categories/presentation/dto/category_response_dto.dart`
- `lib/models/otp_response.dart` → Should be `lib/features/auth/presentation/dto/otp_response_dto.dart`

---

### 2. Routes Contain Business Logic

**Priority**: HIGH

**Violation**: Routes directly call repositories, perform validation, and contain business logic.

**Example 1**: `routes/auth/login.dart` (lines 13-68)
```dart
Future<Response> _login(RequestContext context) async {
  final authRepo = context.read<AuthRepository>();
  
  // Business logic in route handler
  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String?;
  final password = body['password'] as String?;
  
  // Validation in route
  if (email == null || password == null || deviceId == null) {
    return ApiResponse.badRequest(...);
  }
  
  // Business logic: find user, verify password
  final user = await authRepo.findUserByEmail(email);
  if (user == null || !authRepo.verifyPassword(password, user.passwordHash)) {
    return ApiResponse.unauthorized(...);
  }
  
  // Business logic: generate tokens
  final accessToken = authRepo.generateAccessToken(user);
  final refreshToken = authRepo.generateRefreshToken();
  
  // Business logic: store refresh token
  await authRepo.storeRefreshToken(...);
  
  // Response formatting
  final response = AuthResponse(...);
  return ApiResponse.success(data: response.toJson(...));
}
```

**Expected**: Route should delegate to handler
```dart
Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _login(context),
    _ => Response(statusCode: 405),
  };
}

Future<Response> _login(RequestContext context) async {
  final handler = context.read<LoginHandler>();
  return handler.handle(context);
}
```

**Other Violations**:
- `routes/expenses/index.dart` (lines 14-125): Contains query parsing, validation, and business logic
- `routes/categories/index.dart` (lines 15-99): Contains validation and business logic
- `routes/auth/register.dart`: Contains validation and business logic
- All other route files follow the same pattern

**Solution**: Extract handlers to `lib/features/[feature]/presentation/handlers/`

---

### 3. Missing Presentation Layer Handlers

**Priority**: HIGH

**Missing**: Handler classes that orchestrate use cases and format responses.

**Need to Create**:
- `lib/features/auth/presentation/handlers/login_handler.dart`
- `lib/features/auth/presentation/handlers/register_handler.dart`
- `lib/features/auth/presentation/handlers/refresh_handler.dart`
- `lib/features/auth/presentation/handlers/logout_handler.dart`
- `lib/features/auth/presentation/handlers/user_handler.dart`
- `lib/features/auth/presentation/handlers/verify_email_handler.dart`
- `lib/features/auth/presentation/handlers/request_password_reset_handler.dart`
- `lib/features/auth/presentation/handlers/reset_password_handler.dart`
- `lib/features/expenses/presentation/handlers/get_expenses_handler.dart`
- `lib/features/expenses/presentation/handlers/create_expense_handler.dart`
- `lib/features/expenses/presentation/handlers/update_expense_handler.dart`
- `lib/features/expenses/presentation/handlers/delete_expense_handler.dart`
- `lib/features/expenses/presentation/handlers/expense_analytics_handler.dart`
- `lib/features/categories/presentation/handlers/get_categories_handler.dart`
- `lib/features/categories/presentation/handlers/create_category_handler.dart`
- `lib/features/categories/presentation/handlers/update_category_handler.dart`
- `lib/features/categories/presentation/handlers/delete_category_handler.dart`

**Handler Pattern**:
```dart
// lib/features/auth/presentation/handlers/login_handler.dart
class LoginHandler {
  final LoginUseCase loginUseCase;
  
  LoginHandler(this.loginUseCase);
  
  Future<Response> handle(RequestContext context) async {
    try {
      // Parse request DTO
      final requestDto = LoginRequestDto.fromJson(
        await context.request.json() as Map<String, dynamic>
      );
      
      // Validate
      final validationResult = requestDto.validate();
      if (validationResult.isLeft()) {
        return ApiResponse.badRequest(
          message: validationResult.left.message
        );
      }
      
      // Call use case
      final result = await loginUseCase.execute(
        email: requestDto.email,
        password: requestDto.password,
        deviceId: requestDto.deviceId,
      );
      
      // Handle result
      return result.fold(
        (failure) => ApiResponse.fromFailure(failure),
        (authResult) => ApiResponse.success(
          data: AuthResponseDto.fromEntity(authResult).toJson(),
        ),
      );
    } catch (e) {
      AppLogger.error('Login handler error: $e');
      return ApiResponse.internalError(message: 'Login failed');
    }
  }
}
```

---

### 4. Missing Domain Layer

**Priority**: HIGH

**Missing Components**:

#### 4.1 Domain Entities
**Need to Create**:
- `lib/features/auth/domain/entities/user.dart` - Pure Dart User entity
- `lib/features/expenses/domain/entities/expense.dart` - Pure Dart Expense entity
- `lib/features/categories/domain/entities/category.dart` - Pure Dart Category entity

**Example**:
```dart
// lib/features/auth/domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.isEmailVerified,
    required this.createdAt,
    this.updatedAt,
  });
  
  // No framework dependencies - pure Dart
}
```

#### 4.2 Abstract Repository Interfaces
**Need to Create**:
- `lib/features/auth/domain/repositories/auth_repository.dart` (interface)
- `lib/features/auth/domain/repositories/user_repository.dart` (interface)
- `lib/features/expenses/domain/repositories/expense_repository.dart` (interface)
- `lib/features/categories/domain/repositories/category_repository.dart` (interface)

**Example**:
```dart
// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, User>> findUserByEmail(String email);
  Future<Either<Failure, User>> findUserById(String userId);
  Future<Either<Failure, void>> storeRefreshToken({
    required String userId,
    required String refreshToken,
    required String deviceId,
  });
  bool verifyPassword(String password, String passwordHash);
  String generateAccessToken(User user);
  String generateRefreshToken();
}
```

#### 4.3 Use Cases
**Need to Create**:
- `lib/features/auth/domain/usecases/login.dart`
- `lib/features/auth/domain/usecases/register.dart`
- `lib/features/auth/domain/usecases/refresh_token.dart`
- `lib/features/expenses/domain/usecases/get_expenses.dart`
- `lib/features/expenses/domain/usecases/create_expense.dart`
- `lib/features/expenses/domain/usecases/update_expense.dart`
- `lib/features/expenses/domain/usecases/delete_expense.dart`
- `lib/features/categories/domain/usecases/get_categories.dart`
- `lib/features/categories/domain/usecases/create_category.dart`

**Example**:
```dart
// lib/features/auth/domain/usecases/login.dart
class Login {
  final AuthRepository authRepository;
  
  Login(this.authRepository);
  
  Future<Either<Failure, AuthResult>> execute({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    // Find user
    final userResult = await authRepository.findUserByEmail(email);
    return userResult.fold(
      (failure) => Left(failure),
      (user) async {
        // Verify password
        if (!authRepository.verifyPassword(password, user.passwordHash)) {
          return Left(UnauthorizedFailure('Invalid credentials'));
        }
        
        // Generate tokens
        final accessToken = authRepository.generateAccessToken(user);
        final refreshToken = authRepository.generateRefreshToken();
        
        // Store refresh token
        final storeResult = await authRepository.storeRefreshToken(
          userId: user.id,
          refreshToken: refreshToken,
          deviceId: deviceId,
        );
        
        return storeResult.fold(
          (failure) => Left(failure),
          (_) => Right(AuthResult(
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken,
          )),
        );
      },
    );
  }
}
```

---

### 5. Missing Data Layer Datasources

**Priority**: MEDIUM

**Current**: Repositories directly access database using Drift.

**Expected**: Repositories orchestrate datasources.

**Need to Create**:
- `lib/features/auth/data/datasources/auth_local_datasource.dart`
- `lib/features/expenses/data/datasources/expense_local_datasource.dart`
- `lib/features/categories/data/datasources/category_local_datasource.dart`

**Example**:
```dart
// lib/features/auth/data/datasources/auth_local_datasource.dart
class AuthLocalDataSource {
  final PocketlyDatabase database;
  
  AuthLocalDataSource(this.database);
  
  Future<UserTableData?> findUserByEmail(String email) async {
    return (database.select(database.users)
      ..where((user) => user.email.equals(email)))
      .getSingleOrNull();
  }
  
  Future<void> storeRefreshToken({
    required String userId,
    required String refreshTokenHash,
    required String deviceId,
    required DateTime expiresAt,
  }) async {
    await database.into(database.refreshTokens).insert(
      RefreshTokensCompanion.insert(
        userId: userId,
        tokenHash: refreshTokenHash,
        deviceId: deviceId,
        expiresAt: Value(expiresAt),
      ),
    );
  }
}
```

**Repository Pattern**:
```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl(this.localDataSource);
  
  @override
  Future<Either<Failure, User>> findUserByEmail(String email) async {
    try {
      final userData = await localDataSource.findUserByEmail(email);
      if (userData == null) {
        return Left(NotFoundFailure('User not found'));
      }
      return Right(_mapToEntity(userData));
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch user: ${e.toString()}'));
    }
  }
  
  User _mapToEntity(UserTableData data) {
    return User(
      id: data.id,
      name: data.name,
      email: data.email,
      passwordHash: data.passwordHash,
      isEmailVerified: data.isEmailVerified,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
```

---

### 6. Model/DTO Location Violations

**Priority**: MEDIUM

**Current**: Response models in `lib/models/`

**Expected**: DTOs in `lib/features/[feature]/presentation/dto/`

**Files to Move**:
- `lib/models/user_response.dart` → `lib/features/auth/presentation/dto/user_response_dto.dart`
- `lib/models/auth_response.dart` → `lib/features/auth/presentation/dto/auth_response_dto.dart`
- `lib/models/expense_response.dart` → `lib/features/expenses/presentation/dto/expense_response_dto.dart`
- `lib/models/category_response.dart` → `lib/features/categories/presentation/dto/category_response_dto.dart`
- `lib/models/otp_response.dart` → `lib/features/auth/presentation/dto/otp_response_dto.dart`

**Note**: These should be renamed to `*_dto.dart` to follow DTO naming convention.

---

## Frontend Architecture Issues

### 1. Missing Use Cases Layer

**Priority**: HIGH

**Violation**: Providers call repositories directly instead of use cases.

**Example**: `lib/features/expenses/presentation/providers/expenses_provider.dart`

**Current** (lines 23, 34, 132, 199, etc.):
```dart
class ExpensesNotifier extends Notifier<ExpensesState> {
  Future<void> _loadExpenses() async {
    // Direct repository call
    final expenses = await expenseHiveRepository.getAllExpenses();
    state = state.copyWith(expenses: expenses, isLoading: false);
  }
  
  Future<void> addExpense(...) async {
    // Direct repository call
    await expenseHiveRepository.addExpense(expense);
  }
}
```

**Expected**: Provider calls use case
```dart
class ExpensesNotifier extends Notifier<ExpensesState> {
  final GetAllExpenses getAllExpensesUseCase;
  final AddExpense addExpenseUseCase;
  
  ExpensesNotifier({
    required this.getAllExpensesUseCase,
    required this.addExpenseUseCase,
  });
  
  Future<void> _loadExpenses() async {
    final result = await getAllExpensesUseCase.execute();
    result.fold(
      (failure) => setError(failure.message),
      (expenses) => state = state.copyWith(expenses: expenses),
    );
  }
  
  Future<void> addExpense(...) async {
    final result = await addExpenseUseCase.execute(...);
    result.fold(
      (failure) => setError(failure.message),
      (expense) => state = state.copyWith(expenses: [...state.expenses, expense]),
    );
  }
}
```

**Need to Create**:
- `lib/features/expenses/domain/usecases/get_all_expenses.dart`
- `lib/features/expenses/domain/usecases/add_expense.dart`
- `lib/features/expenses/domain/usecases/update_expense.dart`
- `lib/features/expenses/domain/usecases/delete_expense.dart`
- `lib/features/expenses/domain/usecases/get_expenses_by_category.dart`
- `lib/features/expenses/domain/usecases/get_expenses_by_date_range.dart`
- `lib/features/authentication/domain/usecases/login.dart`
- `lib/features/authentication/domain/usecases/register.dart`
- `lib/features/authentication/domain/usecases/logout.dart`
- `lib/features/categories/domain/usecases/get_all_categories.dart`
- `lib/features/categories/domain/usecases/sync_categories.dart`

**Use Case Pattern**:
```dart
// lib/features/expenses/domain/usecases/add_expense.dart
class AddExpense {
  final ExpenseRepository repository;
  
  AddExpense(this.repository);
  
  Future<Either<Failure, Expense>> execute({
    required String name,
    required double amount,
    required Category category,
    required DateTime date,
    String? description,
  }) async {
    // Validation
    if (name.trim().isEmpty) {
      return Left(ValidationFailure('Expense name is required'));
    }
    
    if (amount <= 0) {
      return Left(ValidationFailure('Amount must be greater than 0'));
    }
    
    // Create expense entity
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      amount: amount,
      category: category,
      date: date,
      description: description?.trim(),
      updatedAt: DateTime.now(),
      isDeleted: false,
    );
    
    // Save via repository
    return await repository.addExpense(expense);
  }
}
```

---

### 2. Domain Layer Violations

**Priority**: HIGH

**Violation**: Domain layer imports Flutter framework.

**Violations Found**:
1. `lib/features/expenses/domain/repo/expense_hive_repository.dart` (line 1)
   ```dart
   import 'package:flutter/material.dart'; // ❌ Flutter import in domain
   ```

2. `lib/features/expenses/domain/models/category.dart` (line 1)
   ```dart
   import 'package:flutter/material.dart'; // ❌ Flutter import in domain
   ```

**Expected**: Domain layer should be pure Dart with no framework dependencies.

**Solution**:
1. Move `expense_hive_repository.dart` from `domain/repo/` to `data/repositories/`
2. Create pure Dart Category entity in `domain/entities/category.dart`
3. Keep Flutter Category model in `presentation/models/` or `data/models/` for UI needs

**Pure Dart Category Entity**:
```dart
// lib/features/expenses/domain/entities/category.dart
class Category {
  final String id;
  final String name;
  final String iconCode; // String instead of IconData
  final String colorHex; // String instead of Color
  final DateTime updatedAt;
  final bool isDeleted;
  
  const Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorHex,
    required this.updatedAt,
    this.isDeleted = false,
  });
}
```

**Flutter Category Model** (for UI):
```dart
// lib/features/expenses/presentation/models/category_model.dart
import 'package:flutter/material.dart';
import 'package:pocketly/features/expenses/domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final DateTime updatedAt;
  final bool isDeleted;
  
  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.updatedAt,
    this.isDeleted = false,
  });
  
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: IconMapper.getIcon(entity.iconCode),
      color: Color(int.parse(entity.colorHex.replaceFirst('#', '0xFF'))),
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
    );
  }
}
```

---

### 3. Repository Structure Violations

**Priority**: HIGH

**Current**: Repositories in `domain/repo/`

**Expected**:
- Abstract interfaces in `domain/repositories/`
- Implementations in `data/repositories/`

**Files to Move**:
- `lib/features/expenses/domain/repo/expense_hive_repository.dart` → `lib/features/expenses/data/repositories/expense_repository_impl.dart`
- `lib/features/expenses/domain/repo/category_hive_repository.dart` → `lib/features/expenses/data/repositories/category_repository_impl.dart`

**Need to Create**:
- `lib/features/expenses/domain/repositories/expense_repository.dart` (interface)
- `lib/features/expenses/domain/repositories/category_repository.dart` (interface)

**Example**:
```dart
// lib/features/expenses/domain/repositories/expense_repository.dart
abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getAllExpenses();
  Future<Either<Failure, Expense>> getExpenseById(String id);
  Future<Either<Failure, Expense>> addExpense(Expense expense);
  Future<Either<Failure, Expense>> updateExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String id);
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(String categoryId);
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
}
```

```dart
// lib/features/expenses/data/repositories/expense_repository_impl.dart
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remoteDataSource;
  
  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });
  
  @override
  Future<Either<Failure, List<Expense>>> getAllExpenses() async {
    try {
      final expenses = await localDataSource.getAllExpenses();
      return Right(expenses.map(_mapToEntity).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch expenses: ${e.toString()}'));
    }
  }
  
  Expense _mapToEntity(ExpenseHive expenseHive) {
    // Map Hive model to domain entity
  }
}
```

---

### 4. Missing Datasources Layer

**Priority**: MEDIUM

**Current**: Repositories directly access Hive/API.

**Expected**: Repositories orchestrate datasources.

**Need to Create**:
- `lib/features/expenses/data/datasources/local/expense_local_datasource.dart`
- `lib/features/expenses/data/datasources/local/category_local_datasource.dart`
- `lib/features/expenses/data/datasources/remote/expense_remote_datasource.dart`
- `lib/features/expenses/data/datasources/remote/category_remote_datasource.dart`
- `lib/features/authentication/data/datasources/remote/auth_remote_datasource.dart`

**Example**:
```dart
// lib/features/expenses/data/datasources/local/expense_local_datasource.dart
class ExpenseLocalDataSource {
  Box<ExpenseHive> get _box => HiveDatabase.expenseBox;
  
  Future<List<ExpenseHive>> getAllExpenses() async {
    return _box.values.where((e) => !e.isDeleted).toList();
  }
  
  Future<void> addExpense(ExpenseHive expense) async {
    await _box.add(expense);
  }
  
  Future<void> updateExpense(ExpenseHive expense) async {
    final index = _box.values.toList().indexWhere((e) => e.expenseId == expense.expenseId);
    if (index != -1) {
      await _box.putAt(index, expense);
    }
  }
  
  Future<void> deleteExpense(String expenseId) async {
    final expense = _box.values.firstWhere((e) => e.expenseId == expenseId);
    final index = _box.values.toList().indexOf(expense);
    final deletedExpense = expense.copyWith(isDeleted: true);
    await _box.putAt(index, deletedExpense);
  }
}
```

```dart
// lib/features/expenses/data/datasources/remote/expense_remote_datasource.dart
class ExpenseRemoteDataSource {
  final ApiClient apiClient;
  
  ExpenseRemoteDataSource(this.apiClient);
  
  Future<List<ExpenseApiModel>> getExpenses({
    int limit = 50,
    int offset = 0,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await apiClient.dio.get('/expenses', queryParameters: {
      'limit': limit,
      'offset': offset,
      if (categoryId != null) 'categoryId': categoryId,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    });
    
    final data = response.data['data'];
    return (data['expenses'] as List)
        .map((json) => ExpenseApiModel.fromJson(json))
        .toList();
  }
  
  Future<ExpenseApiModel> createExpense({
    required String name,
    required double amount,
    required DateTime date,
    String? categoryId,
    String? description,
  }) async {
    final response = await apiClient.dio.post('/expenses', data: {
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      if (categoryId != null) 'categoryId': categoryId,
      if (description != null) 'description': description,
    });
    return ExpenseApiModel.fromJson(response.data['data']);
  }
}
```

**Repository Orchestration**:
```dart
// lib/features/expenses/data/repositories/expense_repository_impl.dart
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remoteDataSource;
  final NetworkService networkService;
  
  @override
  Future<Either<Failure, Expense>> addExpense(Expense expense) async {
    // Save locally first
    try {
      await localDataSource.addExpense(_mapToHive(expense));
    } catch (e) {
      return Left(DatabaseFailure('Failed to save locally: ${e.toString()}'));
    }
    
    // Try to sync if online
    final isOnline = await networkService.isConnected;
    if (isOnline) {
      try {
        final apiExpense = await remoteDataSource.createExpense(
          name: expense.name,
          amount: expense.amount,
          date: expense.date,
          categoryId: expense.category.id,
          description: expense.description,
        );
        // Update local with server ID
        await localDataSource.replaceExpenseId(expense.id, apiExpense.id);
        return Right(_mapFromApi(apiExpense));
      } catch (e) {
        // Queue for later sync
        return Right(expense); // Return local expense
      }
    }
    
    return Right(expense);
  }
}
```

---

### 5. Models vs Entities Confusion

**Priority**: MEDIUM

**Current**: `domain/models/` contains models.

**Expected**:
- `domain/entities/` for pure Dart classes
- `data/models/` for DTOs with serialization

**Files to Move/Rename**:
- `lib/features/expenses/domain/models/expense.dart` → `lib/features/expenses/domain/entities/expense.dart`
- `lib/features/expenses/domain/models/category.dart` → `lib/features/expenses/domain/entities/category.dart` (after removing Flutter dependencies)
- `lib/features/expenses/domain/models/expense_filter.dart` → `lib/features/expenses/domain/entities/expense_filter.dart`

**Keep in Data Layer**:
- `lib/features/expenses/data/models/expense_api_model.dart` ✓ (already correct)
- `lib/features/expenses/data/models/expense_hive.dart` ✓ (already correct)
- `lib/features/expenses/data/models/category_api_model.dart` ✓ (already correct)
- `lib/features/expenses/data/models/category_hive.dart` ✓ (already correct)

---

### 6. Provider Violations

**Priority**: HIGH

**Violation**: Providers call repositories directly instead of use cases.

**Affected Files**:
- `lib/features/expenses/presentation/providers/expenses_provider.dart`
- `lib/features/expenses/presentation/providers/categories_provider.dart`
- `lib/features/authentication/presentation/providers/auth_provider.dart`

**Example**: `expenses_provider.dart` (lines 23, 34, 132, 199, 219, etc.)
```dart
// ❌ Current: Direct repository calls
final expenses = await expenseHiveRepository.getAllExpenses();
await expenseHiveRepository.addExpense(expense);
await expenseHiveRepository.updateExpense(updatedExpense);
await expenseHiveRepository.deleteExpense(expenseId);
```

**Expected**: Call use cases
```dart
// ✅ Expected: Use case calls
final result = await getAllExpensesUseCase.execute();
final result = await addExpenseUseCase.execute(...);
final result = await updateExpenseUseCase.execute(...);
final result = await deleteExpenseUseCase.execute(expenseId);
```

---

## Detailed Refactoring Roadmap

### Phase 1: Backend Feature Structure Migration

**Goal**: Reorganize backend into feature-based structure.

**Steps**:
1. Create feature folders:
   ```bash
   mkdir -p lib/features/auth/{data,domain,presentation}
   mkdir -p lib/features/expenses/{data,domain,presentation}
   mkdir -p lib/features/categories/{data,domain,presentation}
   ```

2. Move repositories:
   - `lib/repositories/auth/*` → `lib/features/auth/data/repositories/`
   - `lib/repositories/expense/*` → `lib/features/expenses/data/repositories/`
   - `lib/repositories/category/*` → `lib/features/categories/data/repositories/`

3. Move models to DTOs:
   - `lib/models/user_response.dart` → `lib/features/auth/presentation/dto/user_response_dto.dart`
   - `lib/models/auth_response.dart` → `lib/features/auth/presentation/dto/auth_response_dto.dart`
   - `lib/models/expense_response.dart` → `lib/features/expenses/presentation/dto/expense_response_dto.dart`
   - `lib/models/category_response.dart` → `lib/features/categories/presentation/dto/category_response_dto.dart`
   - `lib/models/otp_response.dart` → `lib/features/auth/presentation/dto/otp_response_dto.dart`

4. Update all imports across codebase.

**Estimated Time**: 4-6 hours

---

### Phase 2: Backend Domain Layer Creation

**Goal**: Create domain layer with entities, repository interfaces, and use cases.

**Steps**:
1. Create domain entities:
   - `lib/features/auth/domain/entities/user.dart`
   - `lib/features/expenses/domain/entities/expense.dart`
   - `lib/features/categories/domain/entities/category.dart`

2. Create abstract repository interfaces:
   - `lib/features/auth/domain/repositories/auth_repository.dart`
   - `lib/features/auth/domain/repositories/user_repository.dart`
   - `lib/features/expenses/domain/repositories/expense_repository.dart`
   - `lib/features/categories/domain/repositories/category_repository.dart`

3. Create use cases:
   - Auth: Login, Register, RefreshToken, Logout, VerifyEmail, etc.
   - Expenses: GetExpenses, CreateExpense, UpdateExpense, DeleteExpense
   - Categories: GetCategories, CreateCategory, UpdateCategory, DeleteCategory

4. Update repository implementations to implement domain interfaces.

**Estimated Time**: 8-12 hours

---

### Phase 3: Backend Presentation Layer (Handlers + DTOs)

**Goal**: Extract handlers from routes and create DTOs.

**Steps**:
1. Create request DTOs:
   - `lib/features/auth/presentation/dto/login_request_dto.dart`
   - `lib/features/auth/presentation/dto/register_request_dto.dart`
   - `lib/features/expenses/presentation/dto/create_expense_request_dto.dart`
   - `lib/features/categories/presentation/dto/create_category_request_dto.dart`

2. Create handlers:
   - Extract logic from routes to handlers
   - Handlers orchestrate use cases
   - Handlers format responses using DTOs

3. Update routes to delegate to handlers:
   - Routes become thin delegators
   - Routes handle HTTP concerns only

**Estimated Time**: 6-8 hours

---

### Phase 4: Backend Data Layer (Datasources)

**Goal**: Create datasources layer for database operations.

**Steps**:
1. Create local datasources:
   - `lib/features/auth/data/datasources/auth_local_datasource.dart`
   - `lib/features/expenses/data/datasources/expense_local_datasource.dart`
   - `lib/features/categories/data/datasources/category_local_datasource.dart`

2. Update repositories to use datasources:
   - Repositories orchestrate datasources
   - Repositories handle data transformation

**Estimated Time**: 4-6 hours

---

### Phase 5: Frontend Use Cases Layer

**Goal**: Extract business logic from providers to use cases.

**Steps**:
1. Create use cases:
   - `lib/features/expenses/domain/usecases/get_all_expenses.dart`
   - `lib/features/expenses/domain/usecases/add_expense.dart`
   - `lib/features/expenses/domain/usecases/update_expense.dart`
   - `lib/features/expenses/domain/usecases/delete_expense.dart`
   - `lib/features/authentication/domain/usecases/login.dart`
   - `lib/features/authentication/domain/usecases/register.dart`
   - `lib/features/categories/domain/usecases/get_all_categories.dart`

2. Update providers to call use cases:
   - Remove direct repository calls
   - Inject use cases into providers
   - Handle Either<Failure, Success> results

**Estimated Time**: 6-8 hours

---

### Phase 6: Frontend Datasources Layer

**Goal**: Create datasources layer for local and remote data operations.

**Steps**:
1. Create local datasources:
   - `lib/features/expenses/data/datasources/local/expense_local_datasource.dart`
   - `lib/features/expenses/data/datasources/local/category_local_datasource.dart`

2. Create remote datasources:
   - `lib/features/expenses/data/datasources/remote/expense_remote_datasource.dart`
   - `lib/features/expenses/data/datasources/remote/category_remote_datasource.dart`
   - `lib/features/authentication/data/datasources/remote/auth_remote_datasource.dart`

3. Update repositories to orchestrate datasources:
   - Repositories decide when to use local vs remote
   - Repositories handle sync logic

**Estimated Time**: 4-6 hours

---

### Phase 7: Frontend Domain Cleanup

**Goal**: Fix domain layer violations and repository structure.

**Steps**:
1. Move repositories from domain to data:
   - `domain/repo/expense_hive_repository.dart` → `data/repositories/expense_repository_impl.dart`
   - `domain/repo/category_hive_repository.dart` → `data/repositories/category_repository_impl.dart`

2. Create abstract repository interfaces in domain:
   - `domain/repositories/expense_repository.dart`
   - `domain/repositories/category_repository.dart`

3. Remove Flutter imports from domain:
   - Create pure Dart Category entity
   - Move Flutter Category model to presentation/data layer

4. Rename `domain/models/` to `domain/entities/`:
   - Move expense.dart, category.dart to entities/
   - Update all imports

**Estimated Time**: 4-6 hours

---

## Migration Examples

### Example 1: Converting Backend Route to Handler Pattern

**Before** (`routes/auth/login.dart`):
```dart
Future<Response> _login(RequestContext context) async {
  final authRepo = context.read<AuthRepository>();
  
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final deviceId = body['deviceId'] as String?;
    
    if (email == null || password == null || deviceId == null) {
      return ApiResponse.badRequest(
        message: 'Email, password and device ID are required',
      );
    }
    
    final user = await authRepo.findUserByEmail(email);
    
    if (user == null || !authRepo.verifyPassword(password, user.passwordHash)) {
      return ApiResponse.unauthorized(
        message: 'Invalid email or password',
      );
    }
    
    final accessToken = authRepo.generateAccessToken(user);
    final refreshToken = authRepo.generateRefreshToken();
    
    await authRepo.storeRefreshToken(
      userId: user.id,
      refreshToken: refreshToken,
      deviceId: deviceId,
    );
    
    final response = AuthResponse(
      user: UserResponse.fromEntity(user),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    
    return ApiResponse.success(data: response.toJson(includeTimestamps: true));
  } catch (e) {
    AppLogger.error('Login error: $e');
    return ApiResponse.internalError(
      message: 'Internal server error',
      errors: {'error': e.toString()},
    );
  }
}
```

**After** (`routes/auth/login.dart`):
```dart
Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _login(context),
    _ => Response(statusCode: 405),
  };
}

Future<Response> _login(RequestContext context) async {
  final handler = context.read<LoginHandler>();
  return handler.handle(context);
}
```

**New Handler** (`lib/features/auth/presentation/handlers/login_handler.dart`):
```dart
class LoginHandler {
  final LoginUseCase loginUseCase;
  
  LoginHandler(this.loginUseCase);
  
  Future<Response> handle(RequestContext context) async {
    try {
      final body = await context.request.json() as Map<String, dynamic>;
      
      // Parse and validate request DTO
      final requestDto = LoginRequestDto.fromJson(body);
      final validationResult = requestDto.validate();
      
      if (validationResult.isLeft()) {
        return ApiResponse.badRequest(
          message: validationResult.left.message,
        );
      }
      
      // Call use case
      final result = await loginUseCase.execute(
        email: requestDto.email,
        password: requestDto.password,
        deviceId: requestDto.deviceId,
      );
      
      // Handle result
      return result.fold(
        (failure) => ApiResponse.fromFailure(failure),
        (authResult) => ApiResponse.success(
          data: AuthResponseDto.fromEntity(authResult).toJson(),
        ),
      );
    } catch (e) {
      AppLogger.error('Login handler error: $e');
      return ApiResponse.internalError(message: 'Login failed');
    }
  }
}
```

**New Use Case** (`lib/features/auth/domain/usecases/login.dart`):
```dart
class Login {
  final AuthRepository authRepository;
  
  Login(this.authRepository);
  
  Future<Either<Failure, AuthResult>> execute({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    // Find user
    final userResult = await authRepository.findUserByEmail(email);
    
    return userResult.fold(
      (failure) => Left(failure),
      (user) async {
        // Verify password
        if (!authRepository.verifyPassword(password, user.passwordHash)) {
          return Left(UnauthorizedFailure('Invalid email or password'));
        }
        
        // Generate tokens
        final accessToken = authRepository.generateAccessToken(user);
        final refreshToken = authRepository.generateRefreshToken();
        
        // Store refresh token
        final storeResult = await authRepository.storeRefreshToken(
          userId: user.id,
          refreshToken: refreshToken,
          deviceId: deviceId,
        );
        
        return storeResult.fold(
          (failure) => Left(failure),
          (_) => Right(AuthResult(
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken,
          )),
        );
      },
    );
  }
}
```

---

### Example 2: Creating Frontend Use Case

**Before** (`lib/features/expenses/presentation/providers/expenses_provider.dart`):
```dart
Future<void> addExpense({
  required String name,
  String? description,
  required double amount,
  required Category category,
  required DateTime date,
}) async {
  if (name.trim().isEmpty) {
    setError('Expense name is required');
    return;
  }
  
  if (amount <= 0) {
    setError('Amount must be greater than 0');
    return;
  }
  
  try {
    setLoading(true);
    final now = DateTime.now();
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      amount: amount,
      category: category,
      date: date,
      description: description,
      updatedAt: now,
      isDeleted: false,
    );
    
    final updatedExpenses = [...state.expenses, expense];
    state = state.copyWith(expenses: updatedExpenses, isLoading: false);
    
    await expenseHiveRepository.addExpense(expense);
    await _handleSyncForExpense(expense, SyncOperation.create);
  } catch (e) {
    setError('Failed to add expense: $e');
  }
}
```

**After** - Use Case (`lib/features/expenses/domain/usecases/add_expense.dart`):
```dart
class AddExpense {
  final ExpenseRepository repository;
  
  AddExpense(this.repository);
  
  Future<Either<Failure, Expense>> execute({
    required String name,
    required double amount,
    required Category category,
    required DateTime date,
    String? description,
  }) async {
    // Validation
    if (name.trim().isEmpty) {
      return Left(ValidationFailure('Expense name is required'));
    }
    
    if (amount <= 0) {
      return Left(ValidationFailure('Amount must be greater than 0'));
    }
    
    // Create expense entity
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      amount: amount,
      category: category,
      date: date,
      description: description?.trim(),
      updatedAt: DateTime.now(),
      isDeleted: false,
    );
    
    // Save via repository
    return await repository.addExpense(expense);
  }
}
```

**After** - Provider (`lib/features/expenses/presentation/providers/expenses_provider.dart`):
```dart
class ExpensesNotifier extends Notifier<ExpensesState> {
  final AddExpense addExpenseUseCase;
  final GetAllExpenses getAllExpensesUseCase;
  
  ExpensesNotifier({
    required this.addExpenseUseCase,
    required this.getAllExpensesUseCase,
  });
  
  Future<void> addExpense({
    required String name,
    String? description,
    required double amount,
    required Category category,
    required DateTime date,
  }) async {
    setLoading(true);
    
    final result = await addExpenseUseCase.execute(
      name: name,
      amount: amount,
      category: category,
      date: date,
      description: description,
    );
    
    result.fold(
      (failure) {
        setError(failure.message);
      },
      (expense) {
        final updatedExpenses = [...state.expenses, expense];
        state = state.copyWith(expenses: updatedExpenses, isLoading: false);
        // Handle sync in background
        _handleSyncForExpense(expense, SyncOperation.create);
      },
    );
  }
}
```

---

### Example 3: Moving Repository to Data Layer

**Before** (`lib/features/expenses/domain/repo/expense_hive_repository.dart`):
```dart
import 'package:flutter/material.dart'; // ❌ Flutter import
import 'package:hive/hive.dart';
import 'package:pocketly/core/services/logger_service.dart';
import 'package:pocketly/core/utils/icon_mapper.dart';
import 'package:pocketly/features/expenses/data/database/hive_database.dart';
import 'package:pocketly/features/expenses/data/models/expense_hive.dart';
import 'package:pocketly/features/expenses/domain/models/expense.dart';
import 'package:pocketly/features/expenses/domain/models/category.dart';

class ExpenseHiveRepository {
  // Implementation...
}
```

**After** - Domain Interface (`lib/features/expenses/domain/repositories/expense_repository.dart`):
```dart
// Pure Dart - no Flutter imports
abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getAllExpenses();
  Future<Either<Failure, Expense>> getExpenseById(String id);
  Future<Either<Failure, Expense>> addExpense(Expense expense);
  Future<Either<Failure, Expense>> updateExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String id);
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(String categoryId);
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
}
```

**After** - Data Implementation (`lib/features/expenses/data/repositories/expense_repository_impl.dart`):
```dart
import 'package:flutter/material.dart'; // ✅ OK in data layer
import 'package:hive/hive.dart';
import 'package:pocketly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:pocketly/features/expenses/domain/entities/expense.dart';
import 'package:pocketly/features/expenses/data/datasources/local/expense_local_datasource.dart';
import 'package:pocketly/features/expenses/data/datasources/remote/expense_remote_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final ExpenseRemoteDataSource remoteDataSource;
  
  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });
  
  @override
  Future<Either<Failure, List<Expense>>> getAllExpenses() async {
    try {
      final expenses = await localDataSource.getAllExpenses();
      return Right(expenses.map(_mapToEntity).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch expenses: ${e.toString()}'));
    }
  }
  
  Expense _mapToEntity(ExpenseHive expenseHive) {
    // Map Hive model to domain entity
  }
}
```

---

## File-by-File Refactoring Checklist

### Backend Files

#### Auth Feature
- [ ] Create `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [ ] Create `lib/features/auth/data/repositories/user_repository_impl.dart`
- [ ] Create `lib/features/auth/data/repositories/otp_repository_impl.dart`
- [ ] Create `lib/features/auth/data/datasources/auth_local_datasource.dart`
- [ ] Create `lib/features/auth/domain/entities/user.dart`
- [ ] Create `lib/features/auth/domain/repositories/auth_repository.dart` (interface)
- [ ] Create `lib/features/auth/domain/repositories/user_repository.dart` (interface)
- [ ] Create `lib/features/auth/domain/usecases/login.dart`
- [ ] Create `lib/features/auth/domain/usecases/register.dart`
- [ ] Create `lib/features/auth/domain/usecases/refresh_token.dart`
- [ ] Create `lib/features/auth/presentation/handlers/login_handler.dart`
- [ ] Create `lib/features/auth/presentation/handlers/register_handler.dart`
- [ ] Create `lib/features/auth/presentation/dto/login_request_dto.dart`
- [ ] Create `lib/features/auth/presentation/dto/user_response_dto.dart`
- [ ] Move `lib/models/user_response.dart` → `lib/features/auth/presentation/dto/user_response_dto.dart`
- [ ] Move `lib/models/auth_response.dart` → `lib/features/auth/presentation/dto/auth_response_dto.dart`
- [ ] Update `routes/auth/login.dart` to delegate to handler
- [ ] Update `routes/auth/register.dart` to delegate to handler

#### Expenses Feature
- [ ] Create `lib/features/expenses/data/repositories/expense_repository_impl.dart`
- [ ] Create `lib/features/expenses/data/repositories/expense_query_repository_impl.dart`
- [ ] Create `lib/features/expenses/data/repositories/expense_analytics_repository_impl.dart`
- [ ] Create `lib/features/expenses/data/datasources/expense_local_datasource.dart`
- [ ] Create `lib/features/expenses/domain/entities/expense.dart`
- [ ] Create `lib/features/expenses/domain/repositories/expense_repository.dart` (interface)
- [ ] Create `lib/features/expenses/domain/usecases/get_expenses.dart`
- [ ] Create `lib/features/expenses/domain/usecases/create_expense.dart`
- [ ] Create `lib/features/expenses/presentation/handlers/get_expenses_handler.dart`
- [ ] Create `lib/features/expenses/presentation/handlers/create_expense_handler.dart`
- [ ] Create `lib/features/expenses/presentation/dto/create_expense_request_dto.dart`
- [ ] Move `lib/models/expense_response.dart` → `lib/features/expenses/presentation/dto/expense_response_dto.dart`
- [ ] Update `routes/expenses/index.dart` to delegate to handlers

#### Categories Feature
- [ ] Create `lib/features/categories/data/repositories/category_repository_impl.dart`
- [ ] Create `lib/features/categories/data/datasources/category_local_datasource.dart`
- [ ] Create `lib/features/categories/domain/entities/category.dart`
- [ ] Create `lib/features/categories/domain/repositories/category_repository.dart` (interface)
- [ ] Create `lib/features/categories/domain/usecases/get_categories.dart`
- [ ] Create `lib/features/categories/presentation/handlers/get_categories_handler.dart`
- [ ] Move `lib/models/category_response.dart` → `lib/features/categories/presentation/dto/category_response_dto.dart`
- [ ] Update `routes/categories/index.dart` to delegate to handler

### Frontend Files

#### Expenses Feature
- [ ] Create `lib/features/expenses/domain/entities/expense.dart` (pure Dart)
- [ ] Create `lib/features/expenses/domain/entities/category.dart` (pure Dart, no Flutter)
- [ ] Create `lib/features/expenses/domain/repositories/expense_repository.dart` (interface)
- [ ] Create `lib/features/expenses/domain/repositories/category_repository.dart` (interface)
- [ ] Create `lib/features/expenses/domain/usecases/get_all_expenses.dart`
- [ ] Create `lib/features/expenses/domain/usecases/add_expense.dart`
- [ ] Create `lib/features/expenses/domain/usecases/update_expense.dart`
- [ ] Create `lib/features/expenses/domain/usecases/delete_expense.dart`
- [ ] Create `lib/features/expenses/data/datasources/local/expense_local_datasource.dart`
- [ ] Create `lib/features/expenses/data/datasources/remote/expense_remote_datasource.dart`
- [ ] Move `lib/features/expenses/domain/repo/expense_hive_repository.dart` → `lib/features/expenses/data/repositories/expense_repository_impl.dart`
- [ ] Move `lib/features/expenses/domain/models/expense.dart` → `lib/features/expenses/domain/entities/expense.dart`
- [ ] Move `lib/features/expenses/domain/models/category.dart` → `lib/features/expenses/domain/entities/category.dart` (after removing Flutter)
- [ ] Update `lib/features/expenses/presentation/providers/expenses_provider.dart` to use use cases
- [ ] Update `lib/features/expenses/presentation/providers/categories_provider.dart` to use use cases

#### Authentication Feature
- [ ] Create `lib/features/authentication/domain/usecases/login.dart`
- [ ] Create `lib/features/authentication/domain/usecases/register.dart`
- [ ] Create `lib/features/authentication/data/datasources/remote/auth_remote_datasource.dart`
- [ ] Update `lib/features/authentication/presentation/providers/auth_provider.dart` to use use cases

---

## Testing Strategy

### Unit Tests

**Backend**:
- Test use cases with mocked repositories
- Test handlers with mocked use cases
- Test repositories with mocked datasources
- Test datasources with in-memory database

**Frontend**:
- Test use cases with mocked repositories
- Test providers with mocked use cases
- Test repositories with mocked datasources
- Test datasources with mocked Hive/API

### Integration Tests

**Backend**:
- Test routes end-to-end
- Test feature flows (login → create expense → get expenses)

**Frontend**:
- Test provider flows
- Test sync flows
- Test offline/online scenarios

### Test Coverage Target
- **Domain Layer**: 90%+ (business logic)
- **Data Layer**: 80%+ (repositories, datasources)
- **Presentation Layer**: 70%+ (handlers, providers)

---

## Risk Assessment

### Breaking Changes
- **High Risk**: All imports will change
- **High Risk**: Dependency injection setup will change
- **Medium Risk**: API contracts remain the same (routes unchanged)

### Migration Order
1. **Start with Auth feature** (smallest, most isolated)
2. **Then Expenses** (most complex)
3. **Finally Categories** (simplest)

### Rollback Strategy
- Use feature branches for each phase
- Test thoroughly before merging
- Keep old code commented until migration verified
- Tag commits at each phase completion

### Dependencies
- Update all imports across entire codebase
- Update dependency injection (GetIt/Riverpod providers)
- Update middleware providers
- Update tests

---

## Priority Levels

### High Priority (Do First)
1. ✅ Missing use cases layer (frontend)
2. ✅ Domain layer violations (Flutter imports)
3. ✅ Routes contain business logic (backend)
4. ✅ Missing presentation handlers (backend)
5. ✅ Repository structure violations

### Medium Priority (Do Second)
1. ⚠️ Missing datasources layer
2. ⚠️ Feature-based structure migration
3. ⚠️ Models vs entities confusion

### Low Priority (Do Last)
1. ⚪ Code organization polish
2. ⚪ Naming convention updates
3. ⚪ Documentation updates

---

## Estimated Total Effort

- **Backend Refactoring**: 22-32 hours
- **Frontend Refactoring**: 14-20 hours
- **Testing**: 8-12 hours
- **Total**: 44-64 hours

---

## Next Steps

1. Review and approve this plan
2. Create feature branch: `refactor/architecture-cleanup`
3. Start with Phase 1 (Backend Feature Structure) - Auth feature
4. Test thoroughly after each phase
5. Merge to main after all phases complete

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Status**: Ready for Implementation

