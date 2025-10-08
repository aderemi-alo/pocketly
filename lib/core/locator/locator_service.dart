import 'package:get_it/get_it.dart';
import 'package:pocketly/features/features.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerLazySingleton<ExpenseIsarRepository>(
    () => ExpenseIsarRepository(),
  );
}

ExpenseIsarRepository get expenseIsarRepository =>
    locator<ExpenseIsarRepository>();
