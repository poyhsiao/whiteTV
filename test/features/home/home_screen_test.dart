import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/home/home_screen.dart';
import 'package:white_tv/features/home/home_store.dart';

void main() {
  testWidgets('HomeScreen widget test', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(MockClient()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Run async work to let the microtask and delayed futures complete
    await tester.runAsync(() async {
      await Future.delayed(const Duration(seconds: 1));
    });

    // Scaffold should be visible
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
