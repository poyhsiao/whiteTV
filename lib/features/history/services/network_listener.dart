import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

typedef NetworkCallback = Future<void> Function();
typedef NetworkRestoredCallback = void Function();

class NetworkListener {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  NetworkCallback? onRestored;
  NetworkRestoredCallback? _onNetworkRestored;
  bool _wasOffline = false;

  NetworkListener({
    Connectivity? connectivity,
    this.onRestored,
  }) : _connectivity = connectivity ?? Connectivity() {
    _startListening();
  }

  void setOnNetworkRestored(NetworkRestoredCallback? callback) {
    _onNetworkRestored = callback;
  }

  void _notifyNetworkRestored() {
    _onNetworkRestored?.call();
  }

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);

      if (hasConnection && _wasOffline) {
        await onRestored?.call();
        _notifyNetworkRestored();
      }

      _wasOffline = !hasConnection;
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
