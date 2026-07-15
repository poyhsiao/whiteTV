import 'dart:math';

class InputSession {
  final String id;
  final DateTime createdAt;
  final Duration duration;

  InputSession({
    required this.id,
    required this.createdAt,
    this.duration = const Duration(minutes: 5),
  });

  bool get isValid => DateTime.now().difference(createdAt) < duration;
}

class SessionManager {
  final List<InputSession> _sessions = [];
  final Duration _defaultDuration;

  SessionManager({Duration? duration})
    : _defaultDuration = duration ?? const Duration(minutes: 5);

  InputSession createSession() {
    final session = InputSession(
      id: _generateId(),
      createdAt: DateTime.now(),
      duration: _defaultDuration,
    );
    _sessions.add(session);
    return session;
  }

  // ponytail: cryptographically secure — Random.secure() uses system entropy
  String _generateId() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  List<InputSession> get sessions => List.unmodifiable(_sessions);

  void clear() {
    _sessions.clear();
  }
}
