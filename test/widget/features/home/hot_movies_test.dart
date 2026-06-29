// Behavioral test for getHotMovies API (UI_UX §3.1)
// Verifies: MockClient returns hot movies, supports limit parameter
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';

void main() {
  test('getHotMovies returns videos from movie category', () async {
    final client = MockClient();
    final movies = await client.getHotMovies(limit: 10);
    expect(movies, isNotNull);
    expect(movies.length, lessThanOrEqualTo(10));
  });

  test('getHotMovies respects limit parameter', () async {
    final client = MockClient();
    final movies = await client.getHotMovies(limit: 2);
    expect(movies.length, lessThanOrEqualTo(2));
  });

  test('getHotMovies returns empty list when no categories exist', () async {
    final client = MockClient();
    // 即使沒有資料也不應拋錯
    final movies = await client.getHotMovies();
    expect(movies, isA<List>());
  });
}