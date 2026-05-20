import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/search/widgets/keyboard_input_view.dart';

void main() {
  group('KeyboardInputView', () {
    testWidgets('renders all letter keys A-Z', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardInputView(
              onKeyPressed: (_) {},
            ),
          ),
        ),
      );

      // Check all letters A-Z are present
      for (var i = 65; i <= 90; i++) {
        final letter = String.fromCharCode(i);
        expect(find.text(letter), findsOneWidget);
      }
    });

    testWidgets('renders number keys 0-9', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardInputView(
              onKeyPressed: (_) {},
            ),
          ),
        ),
      );

      // Check numbers 0-9 are present
      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('renders special keys: space, backspace, confirm', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardInputView(
              onKeyPressed: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Space'), findsOneWidget);
      expect(find.text('⌫'), findsOneWidget); // backspace symbol
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('calls onKeyPressed when key is tapped', (tester) async {
      String? pressedKey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardInputView(
              onKeyPressed: (key) {
                pressedKey = key;
              },
            ),
          ),
        ),
      );

      // Tap on letter A
      await tester.tap(find.text('A'));
      await tester.pump();

      expect(pressedKey, equals('A'));
    });

    testWidgets('calls onKeyPressed with correct value for number keys', (tester) async {
      String? pressedKey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardInputView(
              onKeyPressed: (key) {
                pressedKey = key;
              },
            ),
          ),
        ),
      );

      // Tap on number 5
      await tester.tap(find.text('5'));
      await tester.pump();

      expect(pressedKey, equals('5'));
    });

    testWidgets('calls onKeyPressed with correct value for space', (tester) async {
      String? pressedKey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardInputView(
              onKeyPressed: (key) {
                pressedKey = key;
              },
            ),
          ),
        ),
      );

      // Tap on space
      await tester.tap(find.text('Space'));
      await tester.pump();

      expect(pressedKey, equals(' '));
    });

    testWidgets('calls onKeyPressed with correct value for backspace', (tester) async {
      String? pressedKey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardInputView(
              onKeyPressed: (key) {
                pressedKey = key;
              },
            ),
          ),
        ),
      );

      // Tap on backspace
      await tester.tap(find.text('⌫'));
      await tester.pump();

      expect(pressedKey, equals('\b')); // backspace character
    });

    testWidgets('calls onKeyPressed with correct value for confirm', (tester) async {
      String? pressedKey;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardInputView(
              onKeyPressed: (key) {
                pressedKey = key;
              },
            ),
          ),
        ),
      );

      // Tap on confirm
      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(pressedKey, equals('\n')); // enter character
    });

    testWidgets('keyboard has grid layout for D-pad navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyboardInputView(
              onKeyPressed: (_) {},
            ),
          ),
        ),
      );

      // Verify it uses a GridView or similar grid layout
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}