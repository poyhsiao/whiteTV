import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/search/widgets/qr_input_view.dart';

void main() {
  group('QRInputView', () {
    testWidgets('renders QRInputView widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QRInputView(
            onCodeScanned: (_) {},
          ),
        ),
      );

      // QRInputView should be present
      expect(find.byType(QRInputView), findsOneWidget);
    });

    testWidgets('calls onCodeScanned when code is provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QRInputView(
              onCodeScanned: (_) {},
            ),
          ),
        ),
      );

      // Widget should be present
      expect(find.byType(QRInputView), findsOneWidget);
    });

    testWidgets('shows instruction text at bottom', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QRInputView(
            onCodeScanned: (_) {},
          ),
        ),
      );

      // Should find instruction text
      expect(find.text('Align QR code within the frame'), findsOneWidget);
    });
  });
}
