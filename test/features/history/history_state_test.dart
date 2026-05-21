import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/history/history_state.dart';

void main() {
  group('HistoryState', () {
    test('creates with default values', () {
      const state = HistoryState();

      expect(state.records, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isSyncing, false);
    });

    test('copyWith creates new instance with updated values', () {
      const state = HistoryState();
      final updated = state.copyWith(isLoading: true);

      expect(updated.isLoading, true);
      expect(state.isLoading, false);
    });

    test('copyWith clears error when clearError is true', () {
      final state = HistoryState(error: 'Some error');
      final updated = state.copyWith(clearError: true);

      expect(updated.error, isNull);
    });
  });
}
