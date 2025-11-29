import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketly/core/services/services.dart';
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
  locator.registerLazySingleton(() => AppInfoService());
  locator.registerLazySingleton(() => ApiClient(locator(), locator()));

  // API repositories
  locator.registerLazySingleton(() => ExpenseApiRepository(locator()));
  locator.registerLazySingleton(() => CategoryApiRepository(locator()));
  locator.registerLazySingleton(() => AuthRepositoryImpl(locator(), locator()));

  // Local repositories
  locator.registerLazySingleton(() => ExpenseHiveRepository());
  locator.registerLazySingleton(() => CategoryHiveRepository());
}

// Getters for easy access
ExpenseHiveRepository get expenseHiveRepository =>
    locator<ExpenseHiveRepository>();

ExpenseApiRepository get expenseApiRepository =>
    locator<ExpenseApiRepository>();

CategoryApiRepository get categoryApiRepository =>
    locator<CategoryApiRepository>();

NetworkService get networkService => locator<NetworkService>();

TokenStorageService get tokenStorageService => locator<TokenStorageService>();

AppInfoService get appInfoService => locator<AppInfoService>();
