import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/database/database.dart';
import 'package:pocketly_api/repositories/repositories.dart';
import 'package:pocketly_api/services/email_service.dart';

const _emailService = EmailService();

Handler middleware(Handler handler) {
  return handler.use(
    provider<AuthRepository>(
      (context) => AuthRepository(context.read<PocketlyDatabase>()),
    ),
  ).use(
    provider<UserRepository>(
      (context) => UserRepository(context.read<PocketlyDatabase>()),
    ),
  ).use(
    provider<CategoryRepository>(
      (context) => CategoryRepository(context.read<PocketlyDatabase>()),
    ),
  ).use(
    provider<OtpRepository>(
      (context) => OtpRepository(context.read<PocketlyDatabase>()),
    ),
  ).use(provider<EmailService>((_) => _emailService));
}
