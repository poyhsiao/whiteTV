import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:white_tv/core/router/app_router.dart';

void main() {
  group('AppRouter', () {
    test('appRouter has /login route', () {
      bool foundLogin = false;
      for (final route in appRouter.configuration.routes) {
        if (route is GoRoute && route.name == 'login') {
          foundLogin = true;
          break;
        }
      }
      expect(foundLogin, isTrue);
    });

    test('appRouter has /category/:id route', () {
      bool foundCategory = false;
      for (final route in appRouter.configuration.routes) {
        if (route is GoRoute && route.name == 'category-content') {
          foundCategory = true;
          break;
        }
      }
      expect(foundCategory, isTrue);
    });
  });
}
