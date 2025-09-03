import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gate_ease/route_helper.dart';

void main() {
  group('Logout Navigation Tests', () {
    testWidgets('navigateToLogin should clear navigation stack', (
      WidgetTester tester,
    ) async {
      // Create a test app with multiple screens in navigation stack
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Screen')),
            '/home': (context) => const Scaffold(body: Text('Home Screen')),
            '/profile':
                (context) => const Scaffold(body: Text('Profile Screen')),
          },
          home: const TestHomeScreen(),
        ),
      );

      // Navigate to profile screen (simulating user navigation)
      await tester.tap(find.text('Go to Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile Screen'), findsOneWidget);

      // Test logout navigation - should clear stack and go to login
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Should be on login screen
      expect(find.text('Login Screen'), findsOneWidget);

      // Back button should not work (navigation stack should be cleared)
      // This is the key test - if stack is cleared, back button won't navigate
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      expect(navigator.canPop(), false);
    });

    testWidgets('routeUser with empty role should navigate to login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Screen')),
            '/home': (context) => const Scaffold(body: Text('Home Screen')),
          },
          home: const TestRouteScreen(),
        ),
      );

      // Test routing with empty role
      await tester.tap(find.text('Route Empty Role'));
      await tester.pumpAndSettle();

      // Should navigate to login
      expect(find.text('Login Screen'), findsOneWidget);

      // Navigation stack should be cleared
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      expect(navigator.canPop(), false);
    });
  });
}

class TestHomeScreen extends StatelessWidget {
  const TestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Home Screen'),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            child: const Text('Go to Profile'),
          ),
          ElevatedButton(
            onPressed: () => RouteHelper.navigateToLogin(context),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class TestRouteScreen extends StatelessWidget {
  const TestRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Test Route Screen'),
          ElevatedButton(
            onPressed: () => RouteHelper.routeUser(context, '', false),
            child: const Text('Route Empty Role'),
          ),
        ],
      ),
    );
  }
}
