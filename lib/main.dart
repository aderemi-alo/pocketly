import 'package:pocketly/app/app.dart';
import 'package:pocketly/core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locator
  await setupLocator();
  runApp(const ProviderScope(child: PocketlyApp()));
}
