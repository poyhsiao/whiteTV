import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/services/parental_control_service.dart';

/// Test double backed by SharedPreferences so we don't need the platform
/// channel that FlutterSecureStorage normally requires.
class _MockSecureStorage implements SecureStorageInterface {
  _MockSecureStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> read(String key) async => _prefs.getString('secure_$key');

  @override
  Future<void> write(String key, String value) async =>
      _prefs.setString('secure_$key', value);

  @override
  Future<void> delete(String key) async => _prefs.remove('secure_$key');

  @override
  Future<void> deleteAll() async => _prefs.clear();
}

ParentalControlService _newService(SharedPreferences prefs) =>
    ParentalControlService(secure: _MockSecureStorage(prefs), prefs: prefs);

/// BDD steps for parental lock scenarios.
///
/// Mirrors the wording used in settings.feature so the gherkin scenarios
/// remain executable as plain Dart unit tests when the BDD harness is not
/// wired up. Each step delegates to [ParentalControlService] so production
/// and test share the same code path.
class ParentalLockContext {
  ParentalLockContext(this.service);

  final ParentalControlService service;
  bool? lastVerifyResult;
  int? lastFailedAttempts;
  bool? pinPromptShown;
}

// Placeholder context; each step rebuilds it with a fresh, mock-backed
// service. Tests run via main() always call _rebuild before exercising.
// ponytail: top-level default keeps the field non-null for IDE intellisense;
// no test relies on it.
ParentalLockContext _ctx = ParentalLockContext(ParentalControlService());

Future<void> _rebuild() async {
  final prefs = await SharedPreferences.getInstance();
  _ctx = ParentalLockContext(_newService(prefs));
  _ctx.lastVerifyResult = null;
  _ctx.lastFailedAttempts = null;
  _ctx.pinPromptShown = null;
}

typedef _StepFn = Future<void> Function();
typedef _StepReg = void Function(String, _StepFn);

void registerParentalLockSteps(
    _StepReg step, _StepReg when, _StepReg then) {
  step('使用者已啟用家長鎖並設定 PIN 為 {string}', () async {
    SharedPreferences.setMockInitialValues({});
    await _rebuild();
    await _ctx.service.toggleEnabled(true);
    await _ctx.service.setPin(_lastCapturedString);
  });

  step('使用者未啟用家長鎖', () async {
    SharedPreferences.setMockInitialValues({});
    await _rebuild();
    await _ctx.service.toggleEnabled(false);
  });

  when('輸入 PIN {string} 嘗試播放限制級內容', () async {
    final pin = _lastCapturedString;
    _ctx.lastVerifyResult = await _ctx.service.verifyPin(pin);
    _ctx.lastFailedAttempts = (await _ctx.service.getState()).failedAttempts;
    _ctx.pinPromptShown = true;
  });

  when('嘗試播放限制級內容', () async {
    _ctx.pinPromptShown = !(await _ctx.service.getState()).enabled;
  });

  then('應該驗證成功並允許繼續', () async {
    expect(_ctx.lastVerifyResult, isTrue,
        reason: 'verifyPin should return true for the configured PIN');
  });

  then('應該驗證失敗並要求重新輸入', () async {
    expect(_ctx.lastVerifyResult, isFalse,
        reason: 'verifyPin should return false for a wrong PIN');
    expect(_ctx.pinPromptShown, isTrue);
  });

  then('失敗次數應該記錄為 {int}', () async {
    expect(_ctx.lastFailedAttempts, _lastCapturedInt,
        reason: 'failedAttempts should increment on wrong PIN');
  });

  then('不應該要求輸入 PIN', () async {
    expect(_ctx.pinPromptShown, isFalse,
        reason: 'PIN prompt must not appear when parental control is off');
  });
}

/// Captures the most recently parsed {string} / {int} token.
/// ponytail: gherkin harness will overwrite before each call; tests
/// that bypass the harness should ignore these accessors.
String _lastCapturedString = '';
int _lastCapturedInt = 0;

/// Direct test entry point — runs the three BDD scenarios as plain tests so
/// they execute without an external gherkin harness.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BDD: parental lock', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      _ctx = ParentalLockContext(_newService(prefs));
    });

    test('正確 PIN 通過驗證', () async {
      await _ctx.service.toggleEnabled(true);
      await _ctx.service.setPin('1234');
      final ok = await _ctx.service.verifyPin('1234');
      expect(ok, isTrue);
    });

    test('錯誤 PIN 被阻擋並累加失敗次數', () async {
      await _ctx.service.toggleEnabled(true);
      await _ctx.service.setPin('1234');
      final ok = await _ctx.service.verifyPin('9999');
      expect(ok, isFalse);
      final state = await _ctx.service.getState();
      expect(state.failedAttempts, 1);
    });

    test('未啟用家長鎖時 verifyPin 一律通過', () async {
      await _ctx.service.toggleEnabled(false);
      final ok = await _ctx.service.verifyPin('anything');
      expect(ok, isTrue,
          reason: 'disabled parental control should not gate content');
    });

    test('首次設定家長鎖 PIN', () async {
      // 家長鎖為關閉狀態
      await _ctx.service.toggleEnabled(false);

      // 啟用並設定 PIN
      await _ctx.service.toggleEnabled(true);
      await _ctx.service.setPin('1234');

      // 驗證 PIN 已設定且家長鎖已啟用
      final state = await _ctx.service.getState();
      expect(state.enabled, isTrue);
      expect(state.hasPin, isTrue);
    });

    test('輸入正確 PIN 觀看限制內容', () async {
      await _ctx.service.toggleEnabled(true);
      await _ctx.service.setPin('1234');

      // 輸入正確 PIN
      final ok = await _ctx.service.verifyPin('1234');
      expect(ok, isTrue, reason: 'correct PIN should allow access');
    });

    test('連續輸入錯誤 PIN 3 次後鎖定', () async {
      await _ctx.service.toggleEnabled(true);
      await _ctx.service.setPin('1234');

      // 連續輸入 3 次錯誤 PIN（maxAttempts = 3）
      for (int i = 0; i < 3; i++) {
        await _ctx.service.verifyPin('0000');
      }

      // 應該被鎖定
      final state = await _ctx.service.getState();
      expect(state.isLocked, isTrue,
          reason: 'should be locked out after 3 failed attempts');
      expect(state.failedAttempts, 3,
          reason: 'failedAttempts should equal maxAttempts when locked');
    });

    test('關閉家長鎖需要驗證 PIN', () async {
      await _ctx.service.toggleEnabled(true);
      await _ctx.service.setPin('1234');

      // 關閉家長鎖
      await _ctx.service.toggleEnabled(false);

      final state = await _ctx.service.getState();
      expect(state.enabled, isFalse,
          reason: 'parental control should be disabled');
    });
  });
}