import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/player/widgets/settings_panel.dart';

void main() {
  group('SettingsPanel', () {
    testWidgets('shows settings button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsPanel())),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('opens settings dialog on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsPanel())),
      );

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('shows subtitle options in dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsPanel())),
      );

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('字幕'), findsOneWidget);
      // Use .first because "關閉" also appears in the close button
      expect(find.text('關閉').first, findsOneWidget);
      expect(find.text('中文'), findsOneWidget);
      expect(find.text('英文'), findsOneWidget);
    });

    testWidgets('shows audio track options in dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsPanel())),
      );

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('音軌'), findsOneWidget);
      expect(find.text('國語'), findsOneWidget);
      expect(find.text('粵語'), findsOneWidget);
      expect(find.text('英語'), findsOneWidget);
    });
  });
}
