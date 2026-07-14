import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/session_manager.dart';

void main() {
  group('InputSession', () {
    test('newly created session is valid', () {
      final session = InputSession(id: 'abc', createdAt: DateTime.now());
      expect(session.isValid, isTrue);
    });

    test('exposes the configured duration', () {
      final session = InputSession(
        id: 'abc',
        createdAt: DateTime.now(),
        duration: const Duration(seconds: 30),
      );
      expect(session.duration, const Duration(seconds: 30));
    });
  });

  group('SessionManager', () {
    test('starts with no sessions', () {
      final manager = SessionManager();
      expect(manager.sessions, isEmpty);
    });

    test('createSession appends a new entry with a non-empty id', () {
      final manager = SessionManager();
      final session = manager.createSession();

      expect(session.id, isNotEmpty);
      expect(manager.sessions.length, 1);
      expect(manager.sessions.first.id, session.id);
    });

    test('clear() removes every tracked session', () {
      final manager = SessionManager();
      manager.createSession();
      manager.createSession();

      expect(manager.sessions.length, 2);
      manager.clear();
      expect(manager.sessions, isEmpty);
    });

    test('sessions getter returns an unmodifiable view', () {
      final manager = SessionManager();
      manager.createSession();

      expect(
        () => manager.sessions.add(
          InputSession(id: 'x', createdAt: DateTime.now()),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
