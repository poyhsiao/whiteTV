import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/services/settings_storage_service.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/client_factory.dart';

class AuthState {
  final bool isLoggedIn;
  final String? username;
  final String? error;

  const AuthState({this.isLoggedIn = false, this.username, this.error});

  AuthState copyWith({bool? isLoggedIn, String? username, String? error}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      username: username ?? this.username,
      error: error ?? this.error,
    );
  }
}

class AuthStore extends StateNotifier<AuthState> {
  final SettingsStorageService _storage;
  final ApiClient _apiClient;

  AuthStore(this._storage, this._apiClient) : super(const AuthState()) {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final cookie = await _storage.getAuthCookie();
    final username = await _storage.getUsername();
    if (cookie != null && username != null) {
      state = state.copyWith(isLoggedIn: true, username: username);
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final result = await _apiClient.login(username, password);
      if (result != null) {
        await _storage.saveAuthCookie(result['cookie']!);
        await _storage.saveUsername(username);
        state = state.copyWith(
          isLoggedIn: true,
          username: username,
          error: null,
        );
        return true;
      }
      state = state.copyWith(error: '登入失敗');
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAuthCookie();
    await _storage.saveUsername(null);
    state = const AuthState();
  }
}

// Provider for LunaClient
final lunaClientProvider = Provider<ApiClient>((ref) {
  return createApiClient();
});

// AuthStore provider
final authStoreProvider = StateNotifierProvider<AuthStore, AuthState>((ref) {
  final storage = ref.watch(settingsStorageServiceProvider);
  final apiClient = ref.watch(lunaClientProvider);
  return AuthStore(storage, apiClient);
});
