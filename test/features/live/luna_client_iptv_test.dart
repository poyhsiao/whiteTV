import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/data/models/ipvt_channel.dart';

// Test verification of IPTV method signatures and return types
// Note: LunaClient requires dotenv initialization which is not available in unit tests.
// Integration tests should be used for actual API verification.

void main() {
  group('LunaClient IPTV API contracts', () {
    test('IptvChannel has correct JSON serialization', () {
      const channel = IptvChannel(
        id: '1',
        name: 'Test Channel',
        logo: 'http://example.com/logo.png',
        url: 'http://example.com/stream.m3u8',
        group: 'Sports',
      );

      final json = channel.toJson();
      expect(json['id'], '1');
      expect(json['name'], 'Test Channel');
      expect(json['logo'], 'http://example.com/logo.png');
      expect(json['url'], 'http://example.com/stream.m3u8');
      expect(json['group'], 'Sports');

      final fromJson = IptvChannel.fromJson(json);
      expect(fromJson.id, '1');
      expect(fromJson.name, 'Test Channel');
    });

    test('IptvChannel converts to M3uChannel correctly', () {
      const channel = IptvChannel(
        id: 'ch1',
        name: 'ESPN',
        logo: 'http://example.com/espn.png',
        url: 'http://example.com/espn.m3u8',
        group: 'Sports',
      );

      final m3uChannel = channel.toM3uChannel();
      expect(m3uChannel.name, 'ESPN');
      expect(m3uChannel.url, 'http://example.com/espn.m3u8');
      expect(m3uChannel.logoUrl, 'http://example.com/espn.png');
      expect(m3uChannel.groupTitle, 'Sports');
      expect(m3uChannel.tvgId, 'ch1');
    });

    test('IptvChannel handles empty values in fromJson', () {
      final json = <String, dynamic>{
        'id': null,
        'name': null,
        'logo': null,
        'url': null,
      };

      final channel = IptvChannel.fromJson(json);
      expect(channel.id, '');
      expect(channel.name, '');
      expect(channel.logo, '');
      expect(channel.url, '');
    });

    test('IptvChannel.toM3uChannel handles empty logo', () {
      const channel = IptvChannel(
        id: '1',
        name: 'Test',
        logo: '',
        url: 'http://example.com/test.m3u8',
      );

      final m3uChannel = channel.toM3uChannel();
      expect(m3uChannel.logoUrl, isNull);
    });
  });
}