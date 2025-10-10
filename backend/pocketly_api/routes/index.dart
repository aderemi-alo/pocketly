import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'message': 'Welcome to Dart Frog!',
      'status': 'healthy',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
