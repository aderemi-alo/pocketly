import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

final _db = PocketlyDatabase();
final _expenseRepo = ExpenseRepository(_db);
final _expenseQueryRepo = ExpenseQueryRepository(_db);
final _expenseAnalyticsRepo = ExpenseAnalyticsRepository(_db);
final _categoryRepo = CategoryRepository(_db);

Handler middleware(Handler handler) {
  return handler
      .use(provider<PocketlyDatabase>((_) => _db))
      .use(provider<ExpenseRepository>((_) => _expenseRepo))
      .use(provider<ExpenseQueryRepository>((_) => _expenseQueryRepo))
      .use(provider<ExpenseAnalyticsRepository>((_) => _expenseAnalyticsRepo))
      .use(provider<CategoryRepository>((_) => _categoryRepo))
      .use(requireAuth());
}
