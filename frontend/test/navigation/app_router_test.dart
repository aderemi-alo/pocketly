import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketly/core/core.dart';
import 'package:pocketly/core/navigation/app_router.dart';
import 'package:pocketly/features/authentication/presentation/providers/auth_provider.dart';

void main() {
  group('App Router Authentication Guard Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'should redirect unauthenticated user from dashboard to login',
      () async {
        // Create a router with unauthenticated state
        final router = container.read(routerProvider);

        // Simulate navigation to dashboard when unauthenticated
        router.go('/');

        // Wait for redirects to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify user is redirected to login
        expect(router.routeInformationProvider.value.uri.path, AppRoutes.login);
      },
    );

    test(
      'should redirect unauthenticated user from expenses to login',
      () async {
        // Create a router with unauthenticated state
        final router = container.read(routerProvider);

        // Simulate navigation to expenses when unauthenticated
        router.go('/expenses');

        // Wait for redirects to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify user is redirected to login
        expect(router.routeInformationProvider.value.uri.path, AppRoutes.login);
      },
    );

    test(
      'should redirect unauthenticated user from settings to login',
      () async {
        // Create a router with unauthenticated state
        final router = container.read(routerProvider);

        // Simulate navigation to settings when unauthenticated
        router.go('/settings');

        // Wait for redirects to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify user is redirected to login
        expect(router.routeInformationProvider.value.uri.path, AppRoutes.login);
      },
    );

    test('should allow unauthenticated user to access login page', () async {
      // Create a router with unauthenticated state
      final router = container.read(routerProvider);

      // Navigate to login
      router.go(AppRoutes.login);

      // Wait for navigation
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify user remains on login page
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.login);
    });

    test('should allow unauthenticated user to access signup page', () async {
      // Create a router with unauthenticated state
      final router = container.read(routerProvider);

      // Navigate to signup
      router.go(AppRoutes.signup);

      // Wait for navigation
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify user remains on signup page
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.signup);
    });

    test(
      'should allow unauthenticated user to access forgot password page',
      () async {
        // Create a router with unauthenticated state
        final router = container.read(routerProvider);

        // Navigate to forgot password
        router.go(AppRoutes.forgotPassword);

        // Wait for navigation
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify user remains on forgot password page
        expect(
          router.routeInformationProvider.value.uri.path,
          AppRoutes.forgotPassword,
        );
      },
    );

    // Note: Testing authenticated scenarios requires mocking the auth provider
    // which would need additional setup. These tests verify the core redirect
    // logic for unauthenticated users.
  });
}
