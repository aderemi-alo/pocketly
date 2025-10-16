import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketly/core/services/api_client.dart';
import 'package:pocketly/core/services/device_id_service.dart';
import 'package:pocketly/core/services/network_service.dart';
import 'package:pocketly/core/services/sync/conflict_resolution_service.dart';
import 'package:pocketly/core/services/sync/sync_manager.dart';
import 'package:pocketly/core/services/sync/sync_queue_service.dart';
import 'package:pocketly/core/services/token_storage_service.dart';
import 'package:pocketly/core/services/theme_service.dart';
import 'package:pocketly/features/features.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Core services
  locator.registerLazySingleton(() => sharedPreferences);
  locator.registerLazySingleton(() => const FlutterSecureStorage());
  locator.registerLazySingleton(() => TokenStorageService(locator()));
  locator.registerLazySingleton(
    () => ThemeService(locator<SharedPreferences>()),
  );
  locator.registerLazySingleton(() => DeviceIdService(locator()));
  locator.registerLazySingleton(() => NetworkService());
  locator.registerLazySingleton(() => ApiClient(locator(), locator()));

  // Sync services
  locator.registerLazySingleton(() => SyncQueueService());
  locator.registerLazySingleton(() => ExpenseCacheManager());
  locator.registerLazySingleton(() => ConflictResolution());

  // API repositories
  locator.registerLazySingleton(() => ExpenseApiRepository(locator()));
  locator.registerLazySingleton(() => CategoryApiRepository(locator()));
  locator.registerLazySingleton(() => AuthRepositoryImpl(locator(), locator()));

  // Local repositories
  locator.registerLazySingleton(() => ExpenseHiveRepository());

  // Sync manager
  locator.registerLazySingleton(
    () => SyncManager(
      syncQueue: locator(),
      networkService: locator(),
      expenseApi: locator(),
      categoryApi: locator(),
      cacheManager: locator(),
      conflictResolver: locator(),
    ),
  );

  // Initialize sync manager
  await locator<SyncManager>().initialize();
}

// Getters for easy access
ExpenseHiveRepository get expenseHiveRepository =>
    locator<ExpenseHiveRepository>();

ExpenseApiRepository get expenseApiRepository =>
    locator<ExpenseApiRepository>();

CategoryApiRepository get categoryApiRepository =>
    locator<CategoryApiRepository>();

SyncManager get syncManager => locator<SyncManager>();

NetworkService get networkService => locator<NetworkService>();

TokenStorageService get tokenStorageService => locator<TokenStorageService>();

ExpenseCacheManager get expenseCacheManager => locator<ExpenseCacheManager>();

SyncQueueService get syncQueueService => locator<SyncQueueService>();
