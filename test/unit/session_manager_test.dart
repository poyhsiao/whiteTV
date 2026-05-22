import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/services/session_manager.dart';

void main() {
  group('SessionManager', () {
    test('creates session with unique ID', () {
      final manager = SessionManager();
      final session = manager.createSession();

      expect(session.id, isNotEmpty);
      expect(session.id.length, greaterThanOrEqualTo(16));
    });

    test('generates different IDs for each session', () {
      final manager = SessionManager();
      final session1 = manager.createSession();
      final session2 = manager.createSession();

      expect(session1.id, isNot(session2.id));
    });

    test('session expires after timeout', () async {
      final manager = SessionManager(duration: Duration(milliseconds: 100));
      final session = manager.createSession();

      expect(session.isValid, isTrue);
      await Future.delayed(Duration(milliseconds: 150));

      expect(session.isValid, isFalse);
    });

    test('clears all sessions', () {
      final manager = SessionManager();
      manager.createSession();
      manager.createSession();
      manager.clear();

      expect(manager.sessions.length, equals(0));
    });
  });
}