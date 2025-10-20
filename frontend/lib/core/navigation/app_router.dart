import 'dart:async';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

// Helper class to refresh router when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const dashboard = '/';
  static const expenses = '/expenses';
  static const addExpense = 'add';
  static const settings = '/settings';
  static const profileSettings = 'profile';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthPage =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;

      // Redirect to login if not authenticated and not on auth page
      if (!isAuthenticated && !isOnAuthPage) {
        return AppRoutes.login;
      }

      // Redirect to dashboard if authenticated and on auth page
      if (isAuthenticated && isOnAuthPage) {
        return AppRoutes.dashboard;
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupView(),
      ),
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
                routes: [
                  GoRoute(
                    path: AppRoutes.profileSettings,
                    name: 'profileSettings',
                    builder: (context, state) => const ProfileSettingsView(),
                    parentNavigatorKey: _rootNavigatorKey,
                  ),
                ],
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
