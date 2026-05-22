import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/shared/widgets/qr_input_widget.dart';

void main() {
  group('QrInputWidget', () {
    testWidgets('renders QR code when url is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QrInputWidget(
              url: 'http://192.168.1.100:8080/',
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byType(QrInputWidget), findsOneWidget);
    });

    testWidgets('shows loading indicator when url is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QrInputWidget(
              url: '',
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('toggle button is present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QrInputWidget(
              url: 'http://192.168.1.100:8080/',
              onToggle: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard), findsOneWidget);
    });
  });
}