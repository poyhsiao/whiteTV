import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'luna_client.dart';
import 'mock_client.dart';

/// API Client 工廠 - 根據環境變數切換
/// USE_MOCK=true → MockClient
/// USE_MOCK=false → LunaClient

ApiClient createApiClient() {
  // ponytail: default false so production builds use real API; tests override with true
  final useMock = const bool.fromEnvironment('USE_MOCK', defaultValue: false);

  if (useMock) {
    return MockClient();
  }

  return LunaClient();
}

/// Test helper - creates client with explicit env override
ApiClient createApiClientWithEnvOverride(bool useMock) {
  if (useMock) {
    return MockClient();
  }

  return LunaClient();
}

/// Riverpod provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) => createApiClient());
