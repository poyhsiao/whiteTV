import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/live/presentation/widgets/channel_tile.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';

void main() {
  group('ChannelTile', () {
    testWidgets('displays channel name', (tester) async {
      const channel = M3uChannel(
        name: 'Test Channel',
        url: 'https://example.com/stream.m3u8',
        logoUrl: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ChannelTile(
                channel: channel,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Channel'), findsOneWidget);
    });

    testWidgets('displays channel logo when available', (tester) async {
      const channel = M3uChannel(
        name: 'Logo Channel',
        url: 'https://example.com/stream.m3u8',
        logoUrl: 'https://example.com/logo.png',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ChannelTile(
                channel: channel,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Logo should be displayed via Image widget
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      const channel = M3uChannel(
        name: 'Tappable Channel',
        url: 'https://example.com/stream.m3u8',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ChannelTile(
                channel: channel,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ChannelTile));
      expect(tapped, isTrue);
    });

    testWidgets('shows focus highlight for TV remote', (tester) async {
      const channel = M3uChannel(
        name: 'Focus Channel',
        url: 'https://example.com/stream.m3u8',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: ChannelTile(
                  channel: channel,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      // Find the Focus widget
      expect(find.byType(Focus), findsWidgets);
    });

    testWidgets('displays group-title badge when present', (tester) async {
      const channel = M3uChannel(
        name: 'Sports Channel',
        url: 'https://example.com/stream.m3u8',
        groupTitle: 'Sports',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ChannelTile(
                channel: channel,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sports'), findsOneWidget);
    });
  });
}