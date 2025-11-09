import 'package:dart_frog/dart_frog.dart';
import 'package:pocketly_api/database/database.dart';

final _db = PocketlyDatabase();

Handler middleware(Handler handler) {
  return handler
      .use(provider<PocketlyDatabase>((_) => _db))
      .use(requestLogger())
      .use(_corsHeaders());
}

Middleware _corsHeaders() {
  return (handler) {
    return (context) async {
      final response = await handler(context);

      return response.copyWith(
        headers: {
          ...response.headers,
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods':
              'GET, POST, PUT, PATCH, DELETE, OPTIONS',
          'Access-Control-Allow-Headers':
              'Origin, Content-Type, Accept, Authorization',
        },
      );
    };
  };
}
