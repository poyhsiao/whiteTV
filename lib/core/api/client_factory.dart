import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_client.dart';
import 'luna_client.dart';
import 'mock_client.dart';

/// API Client 工廠 - 根據環境變數切換
/// USE_MOCK=true → MockClient
/// USE_MOCK=false → LunaClient

ApiClient createApiClient() {
  final useMock = dotenv.env['USE_MOCK'] == 'true';

  if (useMock) {
    return MockClient();
  }

  return LunaClient();
}