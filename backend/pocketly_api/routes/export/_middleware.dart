import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

Handler middleware(Handler handler) {
  return handler
      .use(
        provider<ExpenseQueryRepository>(
          (context) => ExpenseQueryRepository(context.read<PocketlyDatabase>()),
        ),
      )
      .use(
        provider<CategoryRepository>(
          (context) => CategoryRepository(context.read<PocketlyDatabase>()),
        ),
      )
      .use(requireAuth());
}
