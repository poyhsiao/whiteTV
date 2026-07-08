// luna_client_test.dart - LunaClient API contract tests
// NOTE: LunaClient requires dotenv initialization (accessed in constructor initializer list)
// which is not available in unit tests.
// See: test/features/live/luna_client_iptv_test.dart for contract approach.
// These tests verify API contracts via mock data and model serialization.

import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/models.dart';

void main() {
  group('LunaClient API contracts', () {
    late MockClient client;

    setUp(() {
      client = MockClient();
    });

    test('getCategories returns List<Category>', () async {
      final result = await client.getCategories();
      expect(result, isA<List<Category>>());
      expect(result.length, greaterThan(0));
    });

    test('getVideosByCategory returns List<Video>', () async {
      final result = await client.getVideosByCategory('movie');
      expect(result, isA<List<Video>>());
      expect(result.isNotEmpty, true);
    });

    test('getVideoDetail returns VideoDetail', () async {
      final result = await client.getVideoDetail('movie-1');
      expect(result, isA<VideoDetail>());
      expect(result.id, 'movie-1');
    });

    test('getSources returns List<VideoSource>', () async {
      final result = await client.getSources('movie-1');
      expect(result, isA<List<VideoSource>>());
      expect(result.isNotEmpty, true);
    });

    test('search returns List<Video>', () async {
      final result = await client.search('test');
      expect(result, isA<List<Video>>());
    });

    test('testSourceLatency returns int >= 0', () async {
      final result = await client.testSourceLatency('https://example.com');
      expect(result, isA<int>());
      // Mock returns 50 + (hashCode % 200), valid URLs always >= 0
      expect(result, greaterThanOrEqualTo(0));
    });
  });

  group('ApiClient interface compliance', () {
    test('MockClient implements ApiClient', () {
      final c = MockClient();
      expect(c, isA<ApiClient>());
    });
  });
}
