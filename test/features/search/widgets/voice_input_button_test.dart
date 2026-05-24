import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:white_tv/features/search/services/voice_input_service.dart';
import 'package:white_tv/features/search/widgets/voice_input_button.dart';

class MockVoiceInputService extends Mock implements VoiceInputService {}

void main() {
  group('VoiceInputButton', () {
    late MockVoiceInputService mockService;

    setUp(() {
      mockService = MockVoiceInputService();
    });

    testWidgets('shows microphone icon when idle', (tester) async {
      when(() => mockService.isListening).thenReturn(false);
      when(() => mockService.onResult).thenAnswer((_) => const Stream.empty());
      when(() => mockService.startListening()).thenAnswer((_) async {});
      when(() => mockService.stopListening()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: VoiceInputButton(
            onResult: (_) {},
            service: mockService,
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_none), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('shows mic_none icon when idle', (tester) async {
      when(() => mockService.isListening).thenReturn(false);
      when(() => mockService.onResult).thenAnswer((_) => const Stream.empty());
      when(() => mockService.startListening()).thenAnswer((_) async {});
      when(() => mockService.stopListening()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: VoiceInputButton(
            onResult: (_) {},
            service: mockService,
          ),
        ),
      );

      // When idle (not listening), should show mic_none icon
      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets('shows mic icon when active', (tester) async {
      when(() => mockService.isListening).thenReturn(true);
      when(() => mockService.onResult).thenAnswer((_) => const Stream.empty());
      when(() => mockService.startListening()).thenAnswer((_) async {});
      when(() => mockService.stopListening()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: VoiceInputButton(
            onResult: (_) {},
            service: mockService,
          ),
        ),
      );

      // When listening, should show mic icon (not mic_none)
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('calls startListening when tapped while idle', (tester) async {
      when(() => mockService.isListening).thenReturn(false);
      when(() => mockService.onResult).thenAnswer((_) => const Stream.empty());
      when(() => mockService.startListening()).thenAnswer((_) async {});
      when(() => mockService.stopListening()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: VoiceInputButton(
            onResult: (_) {},
            service: mockService,
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      verify(() => mockService.startListening()).called(1);
    });

    testWidgets('calls stopListening when tapped while active', (tester) async {
      when(() => mockService.isListening).thenReturn(true);
      when(() => mockService.onResult).thenAnswer((_) => const Stream.empty());
      when(() => mockService.startListening()).thenAnswer((_) async {});
      when(() => mockService.stopListening()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: VoiceInputButton(
            onResult: (_) {},
            service: mockService,
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      verify(() => mockService.stopListening()).called(1);
    });

    testWidgets('passes recognized words to onResult callback', (tester) async {
      when(() => mockService.isListening).thenReturn(false);
      when(() => mockService.startListening()).thenAnswer((_) async {});
      when(() => mockService.stopListening()).thenAnswer((_) async {});

      String? capturedResult;
      final controller = StreamController<String>();

      when(() => mockService.onResult).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: VoiceInputButton(
            onResult: (result) => capturedResult = result,
            service: mockService,
          ),
        ),
      );

      // Simulate speech result
      controller.add('hello world');
      await tester.pump();

      expect(capturedResult, 'hello world');
    });
  });
}