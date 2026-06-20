import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart';

void main() {
  group('SourceStatus', () {
    test('available source returns SourceStatus.available', () {
      const source = VideoSource(
        id: '1', name: 'Fast', url: 'http://example.com',
        latency: 100, isAvailable: true,
      );
      expect(source.status, SourceStatus.available);
    });

    test('unavailable source returns SourceStatus.unavailable', () {
      const source = VideoSource(
        id: '2', name: 'Down', url: 'http://example.com',
        latency: 9999, isAvailable: false,
      );
      expect(source.status, SourceStatus.unavailable);
    });

    test('source with latency=0 returns SourceStatus.testing', () {
      const source = VideoSource(
        id: '3', name: 'Testing', url: 'http://example.com',
        latency: 0, isAvailable: true,
      );
      expect(source.status, SourceStatus.testing);
    });
  });
}
