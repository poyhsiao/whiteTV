import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interface for secure storage operations - enables test mocking
abstract interface class SecureStorageInterface {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

/// Default implementation using flutter_secure_storage
class SecureStorageImpl implements SecureStorageInterface {
  final FlutterSecureStorage _storage;

  SecureStorageImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

final parentalControlServiceProvider = Provider<ParentalControlService>((ref) {
  return ParentalControlService();
});

class ParentalControlState {
  final bool enabled;
  final bool hasPin;
  final int failedAttempts;
  final DateTime? lockoutUntil;

  const ParentalControlState({
    this.enabled = false,
    this.hasPin = false,
    this.failedAttempts = 0,
    this.lockoutUntil,
  });

  bool get isLocked {
    if (lockoutUntil == null) return false;
    return DateTime.now().isBefore(lockoutUntil!);
  }
}

class ParentalControlService {
  static const _pinHashKey = 'parental_pin_hash';
  static const _enabledKey = 'parental_enabled';
  static const _failedAttemptsKey = 'parental_failed_attempts';
  static const _lockoutUntilKey = 'parental_lockout_until';
  static const _maxAttempts = 3;
  static const _lockoutDuration = Duration(seconds: 60);

  final SecureStorageInterface _secure;
  SharedPreferences? _prefs;

  ParentalControlService({
    SecureStorageInterface? secure,
    SharedPreferences? prefs,
  })  : _secure = secure ?? SecureStorageImpl(),
        _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<ParentalControlState> getState() async {
    final prefs = await _getPrefs();
    final enabled = prefs.getBool(_enabledKey) ?? false;
    final failedAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
    final lockoutMillis = prefs.getInt(_lockoutUntilKey);
    final lockoutUntil = lockoutMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(lockoutMillis)
        : null;
    final hasPin = await _hasPin();

    return ParentalControlState(
      enabled: enabled,
      hasPin: hasPin,
      failedAttempts: failedAttempts,
      lockoutUntil: lockoutUntil,
    );
  }

  Future<bool> _hasPin() async {
    final hash = await _secure.read(_pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _secure.write(_pinHashKey, hash);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await _getPrefs();

    // Check lockout
    final lockoutMillis = prefs.getInt(_lockoutUntilKey);
    if (lockoutMillis != null) {
      if (DateTime.now().isBefore(
        DateTime.fromMillisecondsSinceEpoch(lockoutMillis),
      )) {
        return false;
      }
      // Lockout expired, reset attempts
      await prefs.remove(_lockoutUntilKey);
      await prefs.setInt(_failedAttemptsKey, 0);
    }

    final hash = await _secure.read(_pinHashKey);
    if (hash == null) return false;

    if (hash == _hashPin(pin)) {
      await prefs.setInt(_failedAttemptsKey, 0);
      return true;
    }

    final attempts = (prefs.getInt(_failedAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_failedAttemptsKey, attempts);

    if (attempts >= _maxAttempts) {
      await prefs.setInt(
        _lockoutUntilKey,
        DateTime.now().add(_lockoutDuration).millisecondsSinceEpoch,
      );
    }

    return false;
  }

  Future<void> toggleEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_enabledKey, enabled);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }
}
