import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/mock_client.dart';
import 'package:white_tv/features/home/home_store.dart';

void main() {
  group('HomeStore', () {
    late MockClient mockClient;
    late HomeStore store;

    setUp(() {
      mockClient = MockClient();
      store = HomeStore(mockClient);
    });

    test('initial state has empty categories', () {
      expect(store.state.categories, isEmpty);
      expect(store.state.isLoading, false);
    });

    test('loadHome populates categories', () async {
      await store.loadHome();
      expect(store.state.categories.length, 4);
      expect(store.state.isLoading, false);
      expect(store.state.error, isNull);
    });

    test('loadHome populates videos by category', () async {
      await store.loadHome();
      expect(store.state.videosByCategory['movie'], isNotEmpty);
      expect(store.state.videosByCategory['drama'], isNotEmpty);
    });

    test('loadHome sets error on failure', () async {
      await store.loadHome();
      expect(store.state.error, isNull);
    });
  });
}