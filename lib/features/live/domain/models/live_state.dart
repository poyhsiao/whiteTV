import 'package:white_tv/features/live/data/models/epg_channel.dart';
import 'package:white_tv/features/live/data/models/m3u_channel.dart';

enum LiveStatus {
  initial,
  loading,
  loaded,
  error,
  timeshift,
}

class LiveState {
  final LiveStatus status;
  final List<M3uChannel> channels;
  final M3uChannel? currentChannel;
  final Map<String, EpgChannel> epgData;
  final String? errorMessage;
  final bool isSignalError;
  final Duration? timeshiftPosition;

  const LiveState({
    required this.status,
    this.channels = const [],
    this.currentChannel,
    this.epgData = const {},
    this.errorMessage,
    this.isSignalError = false,
    this.timeshiftPosition,
  });

  factory LiveState.initial() {
    return const LiveState(status: LiveStatus.initial);
  }

  factory LiveState.loading() {
    return const LiveState(status: LiveStatus.loading);
  }

  LiveState copyWith({
    LiveStatus? status,
    List<M3uChannel>? channels,
    M3uChannel? currentChannel,
    Map<String, EpgChannel>? epgData,
    String? errorMessage,
    bool? isSignalError,
    Duration? timeshiftPosition,
    bool clearErrorMessage = false,
    bool clearTimeshiftPosition = false,
  }) {
    return LiveState(
      status: status ?? this.status,
      channels: channels ?? this.channels,
      currentChannel: currentChannel ?? this.currentChannel,
      epgData: epgData ?? this.epgData,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isSignalError: isSignalError ?? this.isSignalError,
      timeshiftPosition: clearTimeshiftPosition ? null : (timeshiftPosition ?? this.timeshiftPosition),
    );
  }
}