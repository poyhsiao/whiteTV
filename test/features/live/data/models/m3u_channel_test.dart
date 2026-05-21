import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';

void main() {
  group('M3uChannel', () {
    test('parses single entry with all attributes', () {
      const line = '#EXTINF:-1 tvg-id="channel1" tvg-name="Channel 1" tvg-logo="https://example.com/logo.png" group-title="Sports",Channel 1';
      const url = 'https://example.com/stream.m3u8';

      final channel = M3uChannel.parse(line, url);

      expect(channel.name, 'Channel 1');
      expect(channel.url, 'https://example.com/stream.m3u8');
      expect(channel.logoUrl, 'https://example.com/logo.png');
      expect(channel.groupTitle, 'Sports');
      expect(channel.tvgId, 'channel1');
    });

    test('handles entry without optional attributes', () {
      const line = '#EXTINF:-1 tvg-id="" tvg-name="NoLogo Channel" tvg-logo="" group-title="",NoLogo Channel';
      const url = 'https://example.com/no-logo.m3u8';

      final channel = M3uChannel.parse(line, url);

      expect(channel.name, 'NoLogo Channel');
      expect(channel.url, 'https://example.com/no-logo.m3u8');
      expect(channel.logoUrl, isNull);
      expect(channel.groupTitle, isNull);
      expect(channel.tvgId, isNull);
    });

    test('handles line without tvg attributes', () {
      const line = '#EXTINF:-1,Simple Channel';
      const url = 'https://example.com/simple.m3u8';

      final channel = M3uChannel.parse(line, url);

      expect(channel.name, 'Simple Channel');
      expect(channel.url, 'https://example.com/simple.m3u8');
    });

    test('parses group-title with special characters', () {
      const line = '#EXTINF:-1 group-title="News & Sports HD",News Channel';
      const url = 'https://example.com/news.m3u8';

      final channel = M3uChannel.parse(line, url);

      expect(channel.groupTitle, 'News & Sports HD');
    });
  });
}