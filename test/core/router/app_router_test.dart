import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:white_tv/core/router/app_router.dart';

void main() {
  group('AppRouter login route', () {
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
  });
}
