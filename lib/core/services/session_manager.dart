class InputSession {
  final String id;
  final DateTime createdAt;
  final Duration duration;

  InputSession({
    required this.id,
    required this.createdAt,
    this.duration = const Duration(minutes: 5),
  });

  bool get isValid =>
      DateTime.now().difference(createdAt) < duration;
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

  String _generateId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = timestamp.hashCode.abs().toString();
    return '${timestamp.toRadixString(36)}$random';
  }

  List<InputSession> get sessions => List.unmodifiable(_sessions);

  void clear() {
    _sessions.clear();
  }
}