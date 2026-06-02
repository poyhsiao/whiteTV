import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/presentation/screens/remote_guide_screen.dart';

void main() {
  testWidgets('remote guide shows all 5 sections', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RemoteGuideScreen()),
    );

    expect(find.text('遙控器操作說明'), findsOneWidget);
    expect(find.textContaining('▶ 全域按鍵'), findsOneWidget);
    expect(find.textContaining('▶ 播放中'), findsOneWidget);
    expect(find.textContaining('▶ 首頁'), findsOneWidget);

    // Scroll to see remaining sections
    await tester.scrollUntilVisible(find.textContaining('▶ 詳情頁'), 100);
    expect(find.textContaining('▶ 詳情頁'), findsOneWidget);

    await tester.scrollUntilVisible(find.textContaining('▶ 搜尋'), 100);
    expect(find.textContaining('▶ 搜尋'), findsOneWidget);
  });
}
