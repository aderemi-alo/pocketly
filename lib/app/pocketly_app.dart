import 'package:pocketly/core/core.dart';

class PocketlyApp extends ConsumerWidget {
  const PocketlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: MaterialApp.router(
          title: 'Pocketly',
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
