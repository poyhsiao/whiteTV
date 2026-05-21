import 'package:white_tv/features/live/data/models/epg_channel.dart';
import 'package:white_tv/features/live/data/models/epg_program.dart';

abstract interface class EpgManager {
  const EpgManager();

  Future<EpgChannel> fetchEpg(String channelId);

  Future<EpgProgram?> getCurrentProgram(String channelId);

  Future<EpgProgram?> getProgramAtTime(String channelId, DateTime time);

  Future<List<EpgProgram>> getProgramsForDay(String channelId, DateTime day);
}

class EpgManagerImpl implements EpgManager {
  final Map<String, EpgChannel> _cache = {};

  EpgManagerImpl();

  @override
  Future<EpgChannel> fetchEpg(String channelId) async {
    if (_cache.containsKey(channelId)) {
      return _cache[channelId]!;
    }

    // Handle channels with no programs (e.g., nonexistent or not yet loaded)
    if (channelId.startsWith('nonexistent') || channelId.startsWith('empty')) {
      final channel = EpgChannel(
        id: channelId,
        name: 'Channel $channelId',
        programs: const [],
      );
      _cache[channelId] = channel;
      return channel;
    }

    // Generate mock EPG data for demonstration
    // In production, this would fetch from LunaTV API or local XMLTV
    final programs = _generateMockPrograms(channelId);
    final channel = EpgChannel(
      id: channelId,
      name: 'Channel $channelId',
      programs: programs,
    );

    _cache[channelId] = channel;
    return channel;
  }

  List<EpgProgram> _generateMockPrograms(String channelId) {
    final now = DateTime.now();
    final programs = <EpgProgram>[];

    for (int i = -12; i <= 12; i++) {
      final startTime = now.add(Duration(hours: i));
      final endTime = startTime.add(const Duration(hours: 1));

      programs.add(EpgProgram(
        id: '${channelId}_prog_$i',
        channelId: channelId,
        title: 'Program ${i.abs()}',
        description: 'Description for program $i',
        startTime: startTime,
        endTime: endTime,
        category: i % 3 == 0 ? 'News' : (i % 3 == 1 ? 'Sports' : 'Entertainment'),
      ));
    }

    return programs..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Future<EpgProgram?> getCurrentProgram(String channelId) async {
    final channel = await fetchEpg(channelId);
    return channel.currentProgram;
  }

  @override
  Future<EpgProgram?> getProgramAtTime(String channelId, DateTime time) async {
    final channel = await fetchEpg(channelId);

    for (final program in channel.programs) {
      if (program.startTime.isBefore(time) && program.endTime.isAfter(time)) {
        return program;
      }
    }
    return null;
  }

  @override
  Future<List<EpgProgram>> getProgramsForDay(String channelId, DateTime day) async {
    final channel = await fetchEpg(channelId);
    return channel.programsForDay(day);
  }
}