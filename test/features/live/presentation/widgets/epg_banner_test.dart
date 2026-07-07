import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';
import 'package:white_tv/features/live/presentation/widgets/epg_banner.dart';

void main() {
  group('EpgBanner', () {
    testWidgets('顯示當前節目名稱', (tester) async {
      final now = DateTime.now();
      final current = EpgProgram(
        id: 'prog1',
        channelId: 'ch1',
        title: '晨間新聞',
        description: '最新新聞播報',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 30)),
        category: 'News',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpgBanner(currentProgram: current, nextProgram: null),
          ),
        ),
      );

      expect(find.text('晨間新聞'), findsOneWidget);
      expect(find.text('現在'), findsOneWidget);
    });

    testWidgets('同時顯示下一節目名稱', (tester) async {
      final now = DateTime.now();
      final current = EpgProgram(
        id: 'prog1',
        channelId: 'ch1',
        title: '晨間新聞',
        description: 'News',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now.add(const Duration(minutes: 30)),
        category: 'News',
      );
      final next = EpgProgram(
        id: 'prog2',
        channelId: 'ch1',
        title: '天氣預報',
        description: 'Weather',
        startTime: now.add(const Duration(minutes: 30)),
        endTime: now.add(const Duration(hours: 1)),
        category: 'Weather',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpgBanner(currentProgram: current, nextProgram: next),
          ),
        ),
      );

      expect(find.text('晨間新聞'), findsOneWidget);
      expect(find.text('天氣預報'), findsOneWidget);
      expect(find.text('現在'), findsOneWidget);
      expect(find.text('接下來'), findsOneWidget);
    });

    testWidgets('無節目時回傳 SizedBox', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EpgBanner(currentProgram: null, nextProgram: null),
          ),
        ),
      );

      // When both null, EpgBanner returns SizedBox.shrink()
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
