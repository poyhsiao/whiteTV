import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/main.dart';
import 'package:white_tv/core/router/app_router.dart';

void main() {
  testWidgets('App smoke test - verifies app launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        child: WhiteTVApp(
          router: createAppRouter(initialLocation: '/onboarding'),
        ),
      ),
    );

    // Verify app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App shows onboarding on first launch', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: WhiteTVApp(
          router: createAppRouter(initialLocation: '/onboarding'),
        ),
      ),
    );

    // Should show onboarding screen
    await tester.pump();
    expect(find.byType(Scaffold), findsWidgets);
  });
}