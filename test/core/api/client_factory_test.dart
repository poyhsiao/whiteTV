import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/client_factory.dart';
import 'package:white_tv/core/api/mock_client.dart';

void main() {
  test('createApiClientWithEnvOverride returns MockClient when true', () {
    final client = createApiClientWithEnvOverride(true);
    expect(client, isA<MockClient>());
  });
}
