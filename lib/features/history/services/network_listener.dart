import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

typedef NetworkCallback = Future<void> Function();

class NetworkListener {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  NetworkCallback? onRestored;
  bool _wasOffline = false;

  NetworkListener({
    Connectivity? connectivity,
    this.onRestored,
  }) : _connectivity = connectivity ?? Connectivity() {
    _startListening();
  }

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);

      if (hasConnection && _wasOffline) {
        await onRestored?.call();
      }

      _wasOffline = !hasConnection;
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}