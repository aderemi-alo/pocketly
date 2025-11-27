import 'package:flutter_test/flutter_test.dart';
import 'package:pocketly/features/authentication/presentation/views/login_view.dart';
import 'package:pocketly/core/core.dart';

void main() {
  group('LoginView Widget Tests', () {
    testWidgets('should not display "Skip for now" button', (
      WidgetTester tester,
    ) async {
      // Build the LoginView widget
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginView())),
      );

      // Allow the widget to settle
      await tester.pumpAndSettle();

      // Verify that "Skip for now" text is not present
      expect(find.text('Skip for now'), findsNothing);

      // Verify that no TextButton with "Skip for now" exists
      final skipButtons = find.byWidgetPredicate(
        (widget) =>
            widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data == 'Skip for now',
      );
      expect(skipButtons, findsNothing);
    });

    testWidgets('should display login button', (WidgetTester tester) async {
      // Build the LoginView widget
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginView())),
      );

      // Allow the widget to settle
      await tester.pumpAndSettle();

      // Verify that "Sign In" button is present
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should display signup link', (WidgetTester tester) async {
      // Build the LoginView widget
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginView())),
      );

      // Allow the widget to settle
      await tester.pumpAndSettle();

      // Verify that "Sign Up" link is present
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });
}
