import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/presentation/routes/app_routes.dart';
import 'package:nyxia/presentation/routes/route_generator.dart';

void main() {
  group('route_generator_tests', () {
    test('generateRoute returns material routes for known paths', () {
      // this test verifies known routes are resolved to material routes.
      final routes = [
        const RouteSettings(name: AppRoutes.loading),
        const RouteSettings(name: AppRoutes.welcome),
        const RouteSettings(name: AppRoutes.login),
        const RouteSettings(name: AppRoutes.signup),
        const RouteSettings(name: AppRoutes.home),
      ];

      for (final settings in routes) {
        final route = RouteGenerator.generateRoute(settings);
        expect(route, isA<MaterialPageRoute<dynamic>>());
      }
    });

    testWidgets('generateRoute fallback shows undefined route message', (
      WidgetTester tester,
    ) async {
      // this test verifies fallback route ui for unknown path.
      final route =
          RouteGenerator.generateRoute(const RouteSettings(name: '/unknown'))
              as MaterialPageRoute<dynamic>;

      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: route.builder)),
      );

      expect(find.text('No route defined for /unknown'), findsOneWidget);
    });
  });
}
