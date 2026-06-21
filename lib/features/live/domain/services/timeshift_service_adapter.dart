import 'package:white_tv/core/api/api_client.dart';

/// Service-side timeshift adapter.
///
/// Checks whether the backend (LunaTV) supports server-side timeshift
/// for a given channel and retrieves the timeshift stream URL.
class TimeshiftServiceAdapter {
  TimeshiftServiceAdapter(this._apiClient);

  // TODO: Use _apiClient when LunaTV API integration is implemented
  final ApiClient _apiClient;

  /// Check if the server supports timeshift for [channelId].
  ///
  /// Returns `true` if the server can provide a timeshift stream,
  /// `false` otherwise (including on errors).
  Future<bool> checkSupport(String channelId) async {
    if (channelId.isEmpty) return false;

    try {
      // TODO: Call LunaTV API endpoint to check timeshift support
      // Once LunaTV API provides a timeshift support check, replace
      // this stub with the real implementation.
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Get the timeshift stream URL for [channelId].
  ///
  /// Returns `null` while the LunaTV API integration is pending.
  /// Once integrated, this will return a URL for the timeshift segment
  /// between [startOffset] and [endOffset].
  Future<String?> getStream(
    String channelId,
    Duration startOffset,
    Duration endOffset,
  ) async {
    if (channelId.isEmpty) return null;

    // TODO: Call LunaTV API to get timeshift stream URL
    return null;
  }
}
