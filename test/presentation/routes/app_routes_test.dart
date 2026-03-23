import 'package:flutter_test/flutter_test.dart';
import 'package:nyxia/presentation/routes/app_routes.dart';

void main() {
  group('app_routes_tests', () {
    test('route constants match expected paths', () {
      // this test verifies route path constants.
      expect(AppRoutes.loading, '/loading');
      expect(AppRoutes.welcome, '/welcome');
      expect(AppRoutes.login, '/auth/login');
      expect(AppRoutes.signup, '/auth/signup');
      expect(AppRoutes.home, '/home');
    });
  });
}
