import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final FlutterSecureStorage _secure;

  ParentalControlService({
    FlutterSecureStorage? secure,
  }) : _secure = secure ?? const FlutterSecureStorage();

  Future<ParentalControlState> getState() async {
    final prefs = await SharedPreferences.getInstance();
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
    final hash = await _secure.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _secure.write(key: _pinHashKey, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();

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

    final hash = await _secure.read(key: _pinHashKey);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }
}
