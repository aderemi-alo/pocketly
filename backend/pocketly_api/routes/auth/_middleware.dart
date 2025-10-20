import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/services/email_service.dart';

final _db = PocketlyDatabase();
final _authRepo = AuthRepository(_db);
final _userRepo = UserRepository(_db);
final _categoryRepo = CategoryRepository(_db);
final _otpRepo = OtpRepository(_db);
final _emailService = EmailService();

Handler middleware(Handler handler) {
  return handler
      .use(provider<PocketlyDatabase>((_) => _db))
      .use(provider<AuthRepository>((_) => _authRepo))
      .use(provider<UserRepository>((_) => _userRepo))
      .use(provider<CategoryRepository>((_) => _categoryRepo))
      .use(provider<OtpRepository>((_) => _otpRepo))
      .use(provider<EmailService>((_) => _emailService));
}
