import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart' as crypto;
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

  ParentalControlState copyWith({
    bool? enabled,
    bool? hasPin,
    int? failedAttempts,
    DateTime? lockoutUntil,
  }) {
    return ParentalControlState(
      enabled: enabled ?? this.enabled,
      hasPin: hasPin ?? this.hasPin,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
    );
  }
}

class ParentalControlService {
  ParentalControlService({
    SecureStorageInterface? secure,
    this._prefs,
  }) : _secure = secure ?? SecureStorageImpl();

  final SecureStorageInterface _secure;
  SharedPreferences? _prefs;

  static const _pinHashKey = 'parental_pin_hash';
  static const _saltKey = 'parental_pin_salt_v1';
  static const _enabledKey = 'parental_enabled';
  static const _failedAttemptsKey = 'parental_failed_attempts';
  static const _lockoutUntilKey = 'parental_lockout_until';
  static const _maxAttempts = 3;
  // ponytail: 60-second lockout per original design
  static const _lockoutDuration = Duration(seconds: 60);

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<ParentalControlState> getState() async {
    final prefs = await _getPrefs();
    final enabled = prefs.getBool(_enabledKey) ?? false;
    final storedHash = await _secure.read(_pinHashKey);
    final failedAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
    final lockoutStr = prefs.getString(_lockoutUntilKey);
    final lockoutUntil = lockoutStr != null ? DateTime.tryParse(lockoutStr) : null;
    return ParentalControlState(
      enabled: enabled,
      hasPin: storedHash != null,
      failedAttempts: failedAttempts,
      lockoutUntil: lockoutUntil,
    );
  }

  Future<void> toggleEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_enabledKey, enabled);
  }

  // ponytail: original verifyPin handles lockout internally
  Future<bool> verifyPin(String pin) async {
    final prefs = await _getPrefs();

    // ponytail: short-circuit when parental control is disabled (UI_UX §17.2)
    if (!(prefs.getBool(_enabledKey) ?? false)) {
      return true;
    }

    // Check lockout
    final lockoutStr = prefs.getString(_lockoutUntilKey);
    if (lockoutStr != null) {
      final lockoutUntil = DateTime.tryParse(lockoutStr);
      if (lockoutUntil != null && DateTime.now().isBefore(lockoutUntil)) {
        return false;
      }
      // Lockout expired, reset attempts
      await prefs.remove(_lockoutUntilKey);
      await prefs.setInt(_failedAttemptsKey, 0);
    }

    final hash = await _secure.read(_pinHashKey);
    if (hash == null) return false;

    // ponytail: constant-time comparison prevents timing attacks
    final inputHash = await _hashPin(pin);
    if (!_constantTimeEquals(hash, inputHash)) {
      final attempts = (prefs.getInt(_failedAttemptsKey) ?? 0) + 1;
      await prefs.setInt(_failedAttemptsKey, attempts);
      if (attempts >= _maxAttempts) {
        final lockoutUntil = DateTime.now().add(_lockoutDuration);
        await prefs.setString(_lockoutUntilKey, lockoutUntil.toIso8601String());
      }
      return false;
    }

    await prefs.setInt(_failedAttemptsKey, 0);
    return true;
  }

  /// Constant-time string comparison to prevent timing attacks
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  Future<void> setPin(String pin) async {
    final hash = await _hashPin(pin);
    await _secure.write(_pinHashKey, hash);
  }

  Future<void> clearPin() async {
    await _secure.delete(_pinHashKey);
    final prefs = await _getPrefs();
    await prefs.setInt(_failedAttemptsKey, 0);
  }

  Future<void> recordFailedAttempt() async {
    final prefs = await _getPrefs();
    final attempts = (prefs.getInt(_failedAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_failedAttemptsKey, attempts);
    if (attempts >= _maxAttempts) {
      final lockoutUntil = DateTime.now().add(_lockoutDuration);
      await prefs.setString(_lockoutUntilKey, lockoutUntil.toIso8601String());
    }
  }

  Future<void> resetFailedAttempts() async {
    final prefs = await _getPrefs();
    await prefs.setInt(_failedAttemptsKey, 0);
    await prefs.remove(_lockoutUntilKey);
  }

  // ponytail: per-install salt prevents rainbow table attacks on PIN hash
  Future<String> _getSalt() async {
    var salt = await _secure.read(_saltKey);
    if (salt == null) {
      // Generate stable per-install salt using cryptographically secure random
      final random = Random.secure();
      salt = List.generate(16, (_) => random.nextInt(256))
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();
      await _secure.write(_saltKey, salt);
    }
    return salt;
  }

  // ponytail: PBKDF2 via cryptography package — constant-time impl; 100k iterations
  Future<String> _hashPin(String pin) async {
    final salt = await _getSalt();
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: utf8.encode(salt),
    );
    final hashBytes = await secretKey.extractBytes();
    return crypto.sha256.convert(hashBytes).toString();
  }
}
