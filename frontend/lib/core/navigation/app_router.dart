import 'dart:async';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';
import 'package:pocketly/features/authentication/presentation/views/forgot_password_view.dart';
import 'package:pocketly/features/authentication/presentation/views/email_verification_view.dart';
import 'package:pocketly/features/settings/presentation/views/change_password_view.dart';
import 'package:pocketly/core/navigation/auth_guard.dart';

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
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes
        .dashboard, // Try dashboard first, guard will redirect if needed
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),
    // Global redirect removed in favor of route-level guards
    routes: [
      // PUBLIC ROUTES (guest-only)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        redirect: (context, state) => requireGuest(context, state, ref),
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        redirect: (context, state) => requireGuest(context, state, ref),
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        redirect: (context, state) => requireGuest(context, state, ref),
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        name: 'emailVerification',
        // Email verification might be accessible to both, but usually guest
        // If it requires auth token in URL, it might be different.
        // Assuming guest for now as it's part of auth flow.
        redirect: (context, state) => requireGuest(context, state, ref),
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailVerificationView(email: email);
        },
      ),

      // PROTECTED ROUTES (auth required)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        // Apply guard to the shell route to protect all branches
        redirect: (context, state) => requireAuth(context, state, ref),
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
