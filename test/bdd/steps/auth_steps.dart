import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/settings/auth_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication BDD', () {
    test('AuthState defaults to logged out', () {
      const state = AuthState();
      expect(state.isLoggedIn, isFalse);
      expect(state.username, isNull);
      expect(state.error, isNull);
    });

    test('AuthState copyWith sets logged in', () {
      const initial = AuthState();
      final loggedIn = initial.copyWith(isLoggedIn: true, username: 'testuser');
      expect(loggedIn.isLoggedIn, isTrue);
      expect(loggedIn.username, equals('testuser'));
    });

    test('AuthState copyWith sets logged out', () {
      const loggedIn = AuthState(isLoggedIn: true, username: 'testuser');
      final loggedOut = loggedIn.copyWith(isLoggedIn: false);
      expect(loggedOut.isLoggedIn, isFalse);
      // username not cleared by copyWith(null) — only explicit values override
      expect(loggedOut.username, equals('testuser'));
    });

    test('AuthState copyWith sets error', () {
      const initial = AuthState();
      final withError = initial.copyWith(error: 'Invalid credentials');
      expect(withError.error, equals('Invalid credentials'));
      expect(withError.isLoggedIn, isFalse);
    });

    test('AuthState copyWith with new error replaces old', () {
      const state = AuthState(error: 'Old error');
      final updated = state.copyWith(error: 'New error');
      expect(updated.error, equals('New error'));
    });
  });
}
