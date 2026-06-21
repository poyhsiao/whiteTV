import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/favorites/data/models/favorite_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Favorites BDD', () {
    test('FavoriteItem creation', () {
      final item = FavoriteItem(
        id: 'f1', title: 'Test Movie', posterUrl: 'http://t.com/p.jpg',
        type: 'movie', addedAt: DateTime(2026, 1, 1),
      );
      expect(item.id, equals('f1'));
      expect(item.type, equals('movie'));
      expect(item.isAvailable, isTrue);
    });

    test('FavoriteItem copyWith updates fields', () {
      final item = FavoriteItem(
        id: 'f1', title: 'Test', posterUrl: '', type: 'movie', addedAt: DateTime(2026),
      );
      final updated = item.copyWith(isAvailable: false);
      expect(updated.isAvailable, isFalse);
      expect(updated.id, equals('f1'));
    });

    test('FavoriteItem type filtering', () {
      final items = [
        FavoriteItem(id: '1', title: 'M1', posterUrl: '', type: 'movie', addedAt: DateTime(2026)),
        FavoriteItem(id: '2', title: 'S1', posterUrl: '', type: 'series', addedAt: DateTime(2026)),
      ];
      final movies = items.where((i) => i.type == 'movie').toList();
      expect(movies.length, equals(1));
    });
  });
}
