import 'package:pocketly/core/core.dart';
import 'package:pocketly/core/services/theme_service.dart' as theme_service;

class PocketlyApp extends ConsumerStatefulWidget {
  const PocketlyApp({super.key});

  @override
  ConsumerState<PocketlyApp> createState() => _PocketlyAppState();
}

class _PocketlyAppState extends ConsumerState<PocketlyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    ref.read(themeProvider.notifier).updateSystemBrightness(brightness);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        child: MaterialApp.router(
          title: 'Pocketly',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _convertThemeMode(themeState.themeMode),
          routerConfig: router,
        ),
      ),
    );
  }

  ThemeMode _convertThemeMode(theme_service.ThemeMode mode) {
    switch (mode) {
      case theme_service.ThemeMode.light:
        return ThemeMode.light;
      case theme_service.ThemeMode.dark:
        return ThemeMode.dark;
      case theme_service.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}
