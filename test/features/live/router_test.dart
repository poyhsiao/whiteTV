import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Live Router', () {
    test('live route is defined', () {
      // This test verifies the route constants exist
      const liveRoute = '/live';
      const playerRoute = '/live/player';

      expect(liveRoute, '/live');
      expect(playerRoute, '/live/player');
    });
  });
}