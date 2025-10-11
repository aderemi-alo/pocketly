import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/repositories/repositories.dart';

final _db = PocketlyDatabase();
final _authRepo = AuthRepository(_db);
final _userRepo = UserRepository(_db);
final _categoryRepo = CategoryRepository(_db);

Handler middleware(Handler handler) {
  return handler
      .use(provider<PocketlyDatabase>((_) => _db))
      .use(provider<AuthRepository>((_) => _authRepo))
      .use(provider<UserRepository>((_) => _userRepo))
      .use(provider<CategoryRepository>((_) => _categoryRepo));
}
