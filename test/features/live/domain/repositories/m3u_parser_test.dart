import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/repositories/m3u_parser.dart';

void main() {
  group('M3uParser', () {
    late M3uParser parser;

    setUp(() {
      parser = const M3uParserImpl();
    });

    test('parses valid m3u content with single channel', () {
      const content = '''#EXTM3U
#EXTINF:-1 tvg-id="ch1" tvg-name="Channel 1" tvg-logo="https://example.com/logo.png" group-title="Sports",Channel 1
https://example.com/stream1.m3u8
''';

      final channels = parser.parse(content);

      expect(channels.length, 1);
      expect(channels.first.name, 'Channel 1');
      expect(channels.first.url, 'https://example.com/stream1.m3u8');
      expect(channels.first.tvgId, 'ch1');
      expect(channels.first.logoUrl, 'https://example.com/logo.png');
      expect(channels.first.groupTitle, 'Sports');
    });

    test('parses multiple channels from m3u content', () {
      const content = '''#EXTM3U
#EXTINF:-1 tvg-name="Channel 1",Channel 1
https://example.com/stream1.m3u8
#EXTINF:-1 tvg-name="Channel 2",Channel 2
https://example.com/stream2.m3u8
''';

      final channels = parser.parse(content);

      expect(channels.length, 2);
      expect(channels[0].name, 'Channel 1');
      expect(channels[1].name, 'Channel 2');
    });

    test('filters channels by group-title', () {
      const content = '''#EXTM3U
#EXTINF:-1 group-title="Sports",Sports Channel
https://example.com/sports.m3u8
#EXTINF:-1 group-title="News",News Channel
https://example.com/news.m3u8
''';

      final sportsChannels = parser.parse(content, groupTitle: 'Sports');

      expect(sportsChannels.length, 1);
      expect(sportsChannels.first.groupTitle, 'Sports');
    });

    test('returns empty list for invalid m3u content', () {
      const content = 'This is not valid m3u content';

      final channels = parser.parse(content);

      expect(channels, isEmpty);
    });

    test('handles channel name with comma correctly', () {
      const content = '''#EXTM3U
#EXTINF:-1 tvg-name="Channel, With Comma",Channel, With Comma
https://example.com/stream.m3u8
''';

      final channels = parser.parse(content);

      expect(channels.length, 1);
      expect(channels.first.name, 'Channel, With Comma');
    });

    test('searchChannels finds channels by name', () {
      const content = '''#EXTM3U
#EXTINF:-1 tvg-name="ESPN Sports",Sports Channel
https://example.com/sports.m3u8
#EXTINF:-1 tvg-name="BBC News",News Channel
https://example.com/news.m3u8
''';

      final results = parser.searchChannels(content, query: 'sports');

      expect(results.length, 1);
      expect(results.first.name, 'ESPN Sports');
    });
  });
}