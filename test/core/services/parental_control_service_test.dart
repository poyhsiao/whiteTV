import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/services/parental_control_service.dart';

/// Test implementation of secure storage using SharedPreferences
class MockSecureStorage implements SecureStorageInterface {
  final SharedPreferences _prefs;

  MockSecureStorage(this._prefs);

  @override
  Future<String?> read(String key) async {
    return _prefs.getString('secure_$key');
  }

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString('secure_$key', value);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove('secure_$key');
  }

  @override
  Future<void> deleteAll() async {
    await _prefs.clear();
  }
}

void main() {
  late ParentalControlService service;
  late SharedPreferences prefs;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = ParentalControlService(
      secure: MockSecureStorage(prefs),
      prefs: prefs,
    );
  });

  group('ParentalControlService', () {
    test('initial state has pin not set and not enabled', () async {
      final state = await service.getState();
      expect(state.enabled, false);
      expect(state.hasPin, false);
    });

    test('setPin stores hashed pin', () async {
      await service.setPin('1234');
      final state = await service.getState();
      expect(state.hasPin, true);
      expect(state.enabled, false);
    });

    test('verifyPin returns true for correct pin', () async {
      await service.setPin('1234');
      final result = await service.verifyPin('1234');
      expect(result, isTrue);
    });

    test('verifyPin returns false for wrong pin', () async {
      await service.setPin('1234');
      final result = await service.verifyPin('0000');
      expect(result, isFalse);
    });

    test('toggleEnabled enables/disables parental control', () async {
      await service.setPin('1234');
      await service.toggleEnabled(true);
      var state = await service.getState();
      expect(state.enabled, isTrue);

      await service.toggleEnabled(false);
      state = await service.getState();
      expect(state.enabled, isFalse);
    });

    test('locks out after 3 failed attempts', () async {
      await service.setPin('1234');
      await service.verifyPin('0000');
      await service.verifyPin('0000');
      await service.verifyPin('0000');
      final result = await service.verifyPin('1234');
      expect(result, isFalse);
    });
  });
}
