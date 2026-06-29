import 'package:white_tv/core/api/api_client_fallbacks.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/features/history/services/history_remote_service.dart';

class MockApiClient extends Mock with ApiClientFallbacks implements ApiClient {}

void main() {
  late HistoryRemoteService service;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    service = HistoryRemoteService(mockApiClient);
  });

  group('HistoryRemoteService', () {
    test('fetchFromRemote returns empty list when API returns empty', () async {
      // Arrange
      when(() => mockApiClient.getUserStats()).thenAnswer(
        (_) async => {
          'stats': {'continueWatch': []},
        },
      );

      // Act
      final result = await service.fetchFromRemote();

      // Assert
      expect(result, isEmpty);
      verify(() => mockApiClient.getUserStats()).called(1);
    });

    test('fetchFromRemote parses continueWatch correctly', () async {
      // Arrange
      when(() => mockApiClient.getUserStats()).thenAnswer(
        (_) async => {
          'stats': {
            'continueWatch': [
              {
                'title': '測試影片',
                'source_name': '量子資源',
                'cover': 'https://example.com/cover.jpg',
                'year': '2024',
                'index': 5,
                'total_episodes': 24,
                'play_time': 1800,
                'total_time': 3600,
                'save_time': 1704067200000,
              },
            ],
          },
        },
      );

      // Act
      final result = await service.fetchFromRemote();

      // Assert
      expect(result.length, 1);
      expect(result[0].title, '測試影片');
      expect(result[0].sourceName, '量子資源');
      expect(result[0].posterUrl, 'https://example.com/cover.jpg');
      expect(result[0].currentEpisode, 5);
      expect(result[0].totalEpisodes, 24);
      expect(result[0].playTime, 1800);
      expect(result[0].totalTime, 3600);
      verify(() => mockApiClient.getUserStats()).called(1);
    });

    test('fetchFromRemote generates key from source_name and title', () async {
      // Arrange
      when(() => mockApiClient.getUserStats()).thenAnswer(
        (_) async => {
          'stats': {
            'continueWatch': [
              {
                'title': '測試影片',
                'source_name': '量子資源',
                'cover': 'https://example.com/cover.jpg',
                'year': '2024',
                'index': 5,
                'total_episodes': 24,
                'play_time': 1800,
                'total_time': 3600,
                'save_time': 1704067200000,
              },
            ],
          },
        },
      );

      // Act
      final result = await service.fetchFromRemote();

      // Assert
      expect(result[0].key, '量子資源_測試影片_2024');
    });
  });
}
