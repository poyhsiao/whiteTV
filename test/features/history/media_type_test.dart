import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/models/media_type.dart';

void main() {
  group('MediaType', () {
    test('fromString returns correct type for movie', () {
      final type = MediaType.fromString('movie');
      expect(type, MediaType.movie);
    });

    test('fromString returns correct type for series', () {
      final type = MediaType.fromString('series');
      expect(type, MediaType.series);
    });

    test('fromString returns movie for unknown value', () {
      final type = MediaType.fromString('unknown');
      expect(type, MediaType.movie);
    });

    test('enum values contain all expected types', () {
      expect(MediaType.values, containsAll([
        MediaType.movie,
        MediaType.series,
        MediaType.anime,
        MediaType.variety,
      ]));
    });
  });
}