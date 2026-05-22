import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/utils/time_formatter.dart';

void main() {
  group('TimeFormatter', () {
    group('formatWatchTime', () {
      test('formats seconds when less than 60 seconds', () {
        expect(TimeFormatter.formatWatchTime(0), '0s');
        expect(TimeFormatter.formatWatchTime(30), '30s');
        expect(TimeFormatter.formatWatchTime(45), '45s');
        expect(TimeFormatter.formatWatchTime(59), '59s');
      });

      test('formats minutes when less than 1 hour', () {
        expect(TimeFormatter.formatWatchTime(60), '1m');
        expect(TimeFormatter.formatWatchTime(90), '1m');
      });

      test('formats hours and minutes when >= 1 hour', () {
        expect(TimeFormatter.formatWatchTime(3600), '1h 0m');
        expect(TimeFormatter.formatWatchTime(3660), '1h 1m');
        expect(TimeFormatter.formatWatchTime(5400), '1h 30m');
      });

      test('formats days and hours when >= 24 hours', () {
        expect(TimeFormatter.formatWatchTime(86400), '1d 0h');
        expect(TimeFormatter.formatWatchTime(90000), '1d 1h');
        expect(TimeFormatter.formatWatchTime(169200), '1d 23h');
        expect(TimeFormatter.formatWatchTime(172800), '2d 0h');
      });
    });

    group('formatDuration', () {
      test('formats Duration objects correctly', () {
        expect(TimeFormatter.formatDuration(Duration.zero), '0s');
        expect(TimeFormatter.formatDuration(Duration(seconds: 30)), '30s');
        expect(TimeFormatter.formatDuration(Duration(minutes: 30)), '30m');
        expect(TimeFormatter.formatDuration(Duration(hours: 1, minutes: 30)), '1h 30m');
        expect(TimeFormatter.formatDuration(Duration(days: 1, hours: 2)), '1d 2h');
      });
    });
  });
}