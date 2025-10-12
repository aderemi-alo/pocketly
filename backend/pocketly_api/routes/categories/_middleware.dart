import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/utils/utils.dart';

final _db = PocketlyDatabase();
final _categoryRepo = CategoryRepository(_db);

Handler middleware(Handler handler) {
  return handler
      .use(provider<PocketlyDatabase>((_) => _db))
      .use(provider<CategoryRepository>((_) => _categoryRepo))
      .use(requireAuth());
}
