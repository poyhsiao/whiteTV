// TDD 紅/綠: RecommendationReasonSheet 渲染 reason 欄位
// 規範: docs/spec/UI_UX.md §12 相關推薦 — 顯示推薦理由
// 目標: 驗證 sheet 正確渲染 recommendation.reason 文字

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/recommend/data/models/ai_recommendation.dart';
import 'package:white_tv/features/recommend/presentation/widgets/recommendation_reason_sheet.dart';

void main() {
  group('RecommendationReasonSheet', () {
    testWidgets('有 reason 時渲染文字', (tester) async {
      const rec = AIRecommendation(
        id: 'r1',
        title: '星際效應',
        source: 'src',
        sourceName: '量子資源',
        sourceType: RecommendationSource.ai,
        reason: '你曾看過「黑暗騎士」,AI 推薦類似科幻題材',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RecommendationReasonSheet(recommendation: rec)),
        ),
      );

      expect(find.textContaining('你曾看過'), findsOneWidget);
    });

    testWidgets('無 reason 時不渲染 reason 區塊', (tester) async {
      const rec = AIRecommendation(
        id: 'r2',
        title: '熱門電影',
        source: 'src',
        sourceName: '量子資源',
        sourceType: RecommendationSource.popular,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RecommendationReasonSheet(recommendation: rec)),
        ),
      );

      expect(find.text('熱門電影'), findsOneWidget);
      expect(find.textContaining('AI 推薦'), findsNothing);
    });

    testWidgets('標題始終渲染', (tester) async {
      const rec = AIRecommendation(
        id: 'r3',
        title: '全面啟動',
        source: 'src',
        sourceName: '量子資源',
        sourceType: RecommendationSource.ai,
        reason: '高評分科幻',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RecommendationReasonSheet(recommendation: rec)),
        ),
      );

      expect(find.text('全面啟動'), findsOneWidget);
    });
  });
}
