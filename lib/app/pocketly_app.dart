import 'package:pocketly/core/core.dart';

class PocketlyApp extends ConsumerWidget {
  const PocketlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return ProviderScope(
      child: MaterialApp.router(
        title: 'Pocketly',
        themeMode: ThemeMode.light,
        routerConfig: router,
      ),
    );
  }
}
