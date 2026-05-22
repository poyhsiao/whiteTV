import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  group('FavoriteItem', () {
    test('creates favorite item with required fields', () {
      final item = FavoriteItem(
        id: 'movie-001',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime(2026, 5, 21),
      );

      expect(item.id, 'movie-001');
      expect(item.title, '星際穿越');
      expect(item.posterUrl, 'https://example.com/poster.jpg');
      expect(item.type, 'movie');
      expect(item.isAvailable, true);
      expect(item.addedAt, DateTime(2026, 5, 21));
    });

    test('creates favorite item with isAvailable false', () {
      final item = FavoriteItem(
        id: 'movie-001',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        isAvailable: false,
        addedAt: DateTime(2026, 5, 21),
      );

      expect(item.isAvailable, false);
    });

    test('supports copyWith for immutable updates', () {
      final item = FavoriteItem(
        id: 'movie-001',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime(2026, 5, 21),
      );

      final updated = item.copyWith(title: '星際穿越 (IMAX)');
      expect(updated.title, '星際穿越 (IMAX)');
      expect(item.title, '星際穿越'); // original unchanged
    });

    test('copyWith preserves other fields', () {
      final item = FavoriteItem(
        id: 'movie-001',
        title: '星際穿越',
        posterUrl: 'https://example.com/poster.jpg',
        type: 'movie',
        addedAt: DateTime(2026, 5, 21),
      );

      final updated = item.copyWith(isAvailable: false);
      expect(updated.id, 'movie-001');
      expect(updated.title, '星際穿越');
      expect(updated.type, 'movie');
      expect(updated.isAvailable, false);
    });

    test('types are movie, series, anime, variety', () {
      final movie = FavoriteItem(
        id: '1', title: '電影', posterUrl: '', type: 'movie', addedAt: DateTime.now(),
      );
      final series = FavoriteItem(
        id: '2', title: '劇集', posterUrl: '', type: 'series', addedAt: DateTime.now(),
      );
      final anime = FavoriteItem(
        id: '3', title: '動漫', posterUrl: '', type: 'anime', addedAt: DateTime.now(),
      );
      final variety = FavoriteItem(
        id: '4', title: '綜藝', posterUrl: '', type: 'variety', addedAt: DateTime.now(),
      );

      expect(movie.type, 'movie');
      expect(series.type, 'series');
      expect(anime.type, 'anime');
      expect(variety.type, 'variety');
    });
  });
}