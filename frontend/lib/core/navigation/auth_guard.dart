import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketly/core/navigation/app_router.dart';
import 'package:pocketly/features/authentication/presentation/providers/auth_provider.dart';

/// Guard that protects routes requiring authentication.
/// Returns null if user is authenticated, otherwise redirects to login.
String? requireAuth(BuildContext context, GoRouterState state, Ref ref) {
  final isAuthenticated = ref.read(authProvider).isAuthenticated;

  if (!isAuthenticated) {
    // Save the intended destination to redirect after login
    // We can use this later to redirect back to the intended page
    // final from = state.uri.toString();
    // return '${AppRoutes.login}?from=$from';
    return AppRoutes.login;
  }

  return null; // User is authenticated, allow access
}

/// Guard that prevents authenticated users from accessing auth pages.
/// Returns null if user is NOT authenticated, otherwise redirects to dashboard.
String? requireGuest(BuildContext context, GoRouterState state, Ref ref) {
  final isAuthenticated = ref.read(authProvider).isAuthenticated;

  if (isAuthenticated) {
    return AppRoutes.dashboard; // Already logged in, go to dashboard
  }

  return null; // User is guest, allow access to auth pages
}
