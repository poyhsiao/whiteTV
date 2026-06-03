import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/services/parental_control_service.dart';

void main() {
  late ParentalControlService service;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    service = ParentalControlService();
  });

  group('ParentalControlService', () {
    testWidgets('initial state has pin not set and not enabled',
        (tester) async {
      final state = await service.getState();
      expect(state.enabled, false);
      expect(state.hasPin, false);
    });

    testWidgets('setPin stores hashed pin', (tester) async {
      await service.setPin('1234');
      final state = await service.getState();
      expect(state.hasPin, true);
      expect(state.enabled, false);
    });

    testWidgets('verifyPin returns true for correct pin', (tester) async {
      await service.setPin('1234');
      final result = await service.verifyPin('1234');
      expect(result, isTrue);
    });

    testWidgets('verifyPin returns false for wrong pin', (tester) async {
      await service.setPin('1234');
      final result = await service.verifyPin('0000');
      expect(result, isFalse);
    });

    testWidgets('toggleEnabled enables/disables parental control',
        (tester) async {
      await service.setPin('1234');
      await service.toggleEnabled(true);
      var state = await service.getState();
      expect(state.enabled, isTrue);

      await service.toggleEnabled(false);
      state = await service.getState();
      expect(state.enabled, isFalse);
    });

    testWidgets('locks out after 3 failed attempts', (tester) async {
      await service.setPin('1234');
      await service.verifyPin('0000');
      await service.verifyPin('0000');
      await service.verifyPin('0000');
      final result = await service.verifyPin('1234');
      expect(result, isFalse);
    });
  });
}
