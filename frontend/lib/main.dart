import 'package:flutter/foundation.dart';
import 'package:pocketly/app/app.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/expenses/data/database/hive_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  AppLogger.initialize();

  // Set up global error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error('Flutter Error', details.exception, details.stack);
    FlutterError.presentError(details);
  };

  // Set up platform error handler
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.fatal('Platform Error', error, stack);
    return true;
  };

  // Initialize Hive
  await HiveDatabase.init();

  // Initialize locator
  await setupLocator();
  runApp(const ProviderScope(child: PocketlyApp()));
}
