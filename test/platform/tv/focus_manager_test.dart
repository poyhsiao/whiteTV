import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/platform/tv/focus_manager.dart';

void main() {
  group('TVFocusManager', () {
    group('D-pad Keys Set', () {
      test('contains standard D-pad keys', () {
        expect(TVFocusManager.dpadKeys, contains(LogicalKeyboardKey.arrowUp));
        expect(TVFocusManager.dpadKeys, contains(LogicalKeyboardKey.arrowDown));
        expect(TVFocusManager.dpadKeys, contains(LogicalKeyboardKey.arrowLeft));
        expect(TVFocusManager.dpadKeys, contains(LogicalKeyboardKey.arrowRight));
        expect(TVFocusManager.dpadKeys, contains(LogicalKeyboardKey.select));
      });

      test('dpadKeys count is 5', () {
        expect(TVFocusManager.dpadKeys.length, equals(5));
      });
    });

    group('Focus Movement', () {
      testWidgets('getNextFocus returns correct direction for arrowUp', (tester) async {
        final focusNode = FocusNode();
        await tester.pumpWidget(
          Focus(
            focusNode: focusNode,
            child: Container(),
          ),
        );

        final result = TVFocusManager.getNextFocus(
          focusNode,
          LogicalKeyboardKey.arrowUp,
        );
        expect(result, equals(FocusMoveDirection.up));
      });

      testWidgets('getNextFocus returns correct direction for arrowDown', (tester) async {
        final focusNode = FocusNode();
        await tester.pumpWidget(
          Focus(
            focusNode: focusNode,
            child: Container(),
          ),
        );

        final result = TVFocusManager.getNextFocus(
          focusNode,
          LogicalKeyboardKey.arrowDown,
        );
        expect(result, equals(FocusMoveDirection.down));
      });

      testWidgets('getNextFocus returns correct direction for arrowLeft', (tester) async {
        final focusNode = FocusNode();
        await tester.pumpWidget(
          Focus(
            focusNode: focusNode,
            child: Container(),
          ),
        );

        final result = TVFocusManager.getNextFocus(
          focusNode,
          LogicalKeyboardKey.arrowLeft,
        );
        expect(result, equals(FocusMoveDirection.left));
      });

      testWidgets('getNextFocus returns correct direction for arrowRight', (tester) async {
        final focusNode = FocusNode();
        await tester.pumpWidget(
          Focus(
            focusNode: focusNode,
            child: Container(),
          ),
        );

        final result = TVFocusManager.getNextFocus(
          focusNode,
          LogicalKeyboardKey.arrowRight,
        );
        expect(result, equals(FocusMoveDirection.right));
      });
    });

    group('D-pad Key Detection', () {
      test('isDpadKey returns true for arrow keys', () {
        expect(TVFocusManager.isDpadKey(LogicalKeyboardKey.arrowUp), isTrue);
        expect(TVFocusManager.isDpadKey(LogicalKeyboardKey.arrowDown), isTrue);
        expect(TVFocusManager.isDpadKey(LogicalKeyboardKey.arrowLeft), isTrue);
        expect(TVFocusManager.isDpadKey(LogicalKeyboardKey.arrowRight), isTrue);
        expect(TVFocusManager.isDpadKey(LogicalKeyboardKey.select), isTrue);
      });

      test('isDpadKey returns false for non-dpad keys', () {
        expect(TVFocusManager.isDpadKey(LogicalKeyboardKey.keyA), isFalse);
        expect(TVFocusManager.isDpadKey(LogicalKeyboardKey.space), isFalse);
        expect(TVFocusManager.isDpadKey(LogicalKeyboardKey.escape), isFalse);
      });
    });
  });
}
