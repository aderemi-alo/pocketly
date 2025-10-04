import 'package:pocketly/core/core.dart';
import 'package:flutter/foundation.dart';

class PocketlyApp extends ConsumerWidget {
  const PocketlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ProviderScope(
      child: MaterialApp.router(
        title: 'Pocketly',
        debugShowCheckedModeBanner: kDebugMode,
        themeMode: ThemeMode.light,
        routerConfig: router,
      ),
    );
  }
}
