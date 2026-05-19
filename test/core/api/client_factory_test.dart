import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/api_client.dart';
import 'package:white_tv/core/api/client_factory.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/core/api/luna_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    // Load .env from project root for tests
    final envPath = '${Directory.current.path}/.env';
    await dotenv.load(fileName: envPath);
  });

  test('createApiClient returns MockClient when USE_MOCK=true', () {
    dotenv.env['USE_MOCK'] = 'true';
    final client = createApiClient();
    expect(client, isA<MockClient>());
  });

  test('createApiClient returns LunaClient when USE_MOCK=false', () {
    dotenv.env['USE_MOCK'] = 'false';
    final client = createApiClient();
    expect(client, isA<LunaClient>());
  });
}