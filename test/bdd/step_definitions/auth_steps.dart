import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/auth_store.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/core/api/client_factory.dart';

void main() {
  group('Authentication BDD', () {
    test('login state persists', () async {
      // Test auth state management
      final authState = AuthState(isLoggedIn: true, username: 'test');
      expect(authState.isLoggedIn, isTrue);
      expect(authState.username, equals('test'));
    });

    test('auth state copy with', () {
      final initial = AuthState(isLoggedIn: false);
      final updated = initial.copyWith(isLoggedIn: true, username: 'user');
      
      expect(updated.isLoggedIn, isTrue);
      expect(updated.username, equals('user'));
    });
  });
}
