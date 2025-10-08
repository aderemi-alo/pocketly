import 'package:pocketly/app/app.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/expenses/data/database/hive_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveDatabase.init();

  // Initialize locator
  await setupLocator();
  runApp(const ProviderScope(child: PocketlyApp()));
}
