import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class AppRoutes {
  static const dashboard = '/';
  static const expenses = '/expenses';
  static const addExpense = 'add';
  static const settings = '/settings';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.expenses,
                name: 'expenses',
                builder: (context, state) => const ExpensesView(),
                routes: [
                  GoRoute(
                    path: AppRoutes.addExpense,
                    name: 'addExpense',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final expense = state.extra as Expense?;
                      return AddEditExpenseScreen(expense: expense);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: 'settings',
                builder: (context, state) => const SettingsView(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.matchedLocation}')),
    ),
  );
});
