import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class AppRoutes {
  static const dashboard = '/';
  static const expensesList = '/expenses';
  static const settings = '/settings';
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        path: AppRoutes.expensesList,
        name: 'expenses-list',
        builder: (context, state) => const ExpensesView(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsView(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.matchedLocation}')),
    ),
  );
});
