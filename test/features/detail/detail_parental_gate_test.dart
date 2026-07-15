import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart';
import 'package:white_tv/features/detail/detail_screen.dart';

void main() {
  group('isAdultContent', () {
    test('returns false for null or non-adult categories', () {
      expect(isAdultContent(null), false);
      expect(isAdultContent(VideoDetail(id: '1', title: 'test')), false);
      expect(
        isAdultContent(VideoDetail(id: '1', title: 'test', category: '電影')),
        false,
      );
    });

    test('returns true for adult keywords', () {
      expect(
        isAdultContent(VideoDetail(id: '1', title: 'test', category: '成人')),
        true,
      );
      expect(
        isAdultContent(VideoDetail(id: '1', title: 'test', category: '18+')),
        true,
      );
      expect(
        isAdultContent(VideoDetail(id: '1', title: 'test', category: '限制級')),
        true,
      );
      expect(
        isAdultContent(VideoDetail(id: '1', title: 'test', category: 'R18')),
        true,
      );
      expect(
        isAdultContent(VideoDetail(id: '1', title: 'test', category: 'adult')),
        true,
      );
    });
  });
}
