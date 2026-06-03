import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/shared/widgets/pin_dialog.dart';

void main() {
  testWidgets('PIN dialog shows keypad and input dots', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PinDialog())),
    );

    expect(find.text('輸入PIN碼'), findsOneWidget);
    for (int i = 0; i <= 9; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
  });

  testWidgets('PIN dialog returns value after 4 digits entered', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<String>(
                  context: context,
                  builder: (_) => const PinDialog(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();

    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('4'));
    await tester.pump();

    expect(result, '1234');
  });
}
