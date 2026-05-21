import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/features/live/domain/models/live_state.dart';

void main() {
  group('LiveState', () {
    test('creates initial state correctly', () {
      final state = LiveState.initial();

      expect(state.status, LiveStatus.initial);
      expect(state.channels, isEmpty);
      expect(state.currentChannel, isNull);
      expect(state.epgData, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.isSignalError, isFalse);
      expect(state.timeshiftPosition, isNull);
    });

    test('creates loading state correctly', () {
      final state = LiveState.loading();

      expect(state.status, LiveStatus.loading);
    });

    test('copyWith updates fields correctly', () {
      final initial = LiveState.initial();
      final updated = initial.copyWith(
        status: LiveStatus.loaded,
        isSignalError: true,
      );

      expect(updated.status, LiveStatus.loaded);
      expect(updated.isSignalError, isTrue);
      expect(initial.status, LiveStatus.initial); // original unchanged
    });

    test('LiveStatus enum has correct values', () {
      expect(LiveStatus.values.length, 5);
      expect(LiveStatus.initial.index, 0);
      expect(LiveStatus.loading.index, 1);
      expect(LiveStatus.loaded.index, 2);
      expect(LiveStatus.error.index, 3);
      expect(LiveStatus.timeshift.index, 4);
    });

    test('signal error state is properly modeled', () {
      const state = LiveState(
        status: LiveStatus.loaded,
        isSignalError: true,
        errorMessage: 'Signal lost',
      );

      expect(state.isSignalError, isTrue);
      expect(state.errorMessage, 'Signal lost');
    });

    test('timeshift state stores position correctly', () {
      final state = LiveState.initial().copyWith(
        status: LiveStatus.timeshift,
        timeshiftPosition: const Duration(hours: 1),
      );

      expect(state.status, LiveStatus.timeshift);
      expect(state.timeshiftPosition, const Duration(hours: 1));
    });
  });
}