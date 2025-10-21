import 'dart:async';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';
import 'package:pocketly/features/authentication/presentation/views/forgot_password_view.dart';
import 'package:pocketly/features/authentication/presentation/views/email_verification_view.dart';
import 'package:pocketly/features/settings/presentation/views/change_password_view.dart';

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
  static const forgotPassword = '/forgot-password';
  static const emailVerification = '/email-verification';
  static const dashboard = '/';
  static const expenses = '/expenses';
  static const addExpense = 'add';
  static const settings = '/settings';
  static const profileSettings = 'profile';
  static const changePassword = 'change-password';
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
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.forgotPassword;

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
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        name: 'emailVerification',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailVerificationView(email: email);
        },
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
                  GoRoute(
                    path: AppRoutes.changePassword,
                    name: 'changePassword',
                    builder: (context, state) => const ChangePasswordView(),
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
