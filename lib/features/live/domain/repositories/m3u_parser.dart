import 'package:white_tv/features/live/data/models/m3u_channel.dart';

abstract interface class M3uParser {
  const M3uParser();

  List<M3uChannel> parse(String content, {String? groupTitle});

  List<M3uChannel> searchChannels(String content, {required String query});
}

class M3uParserImpl implements M3uParser {
  const M3uParserImpl();

  @override
  List<M3uChannel> parse(String content, {String? groupTitle}) {
    final lines = content.split('\n');
    final channels = <M3uChannel>[];
    String? currentExtInf;

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('#EXTINF:')) {
        currentExtInf = trimmed;
      } else if (trimmed.isNotEmpty && !trimmed.startsWith('#') && currentExtInf != null) {
        final channel = M3uChannel.parse(currentExtInf, trimmed);

        if (groupTitle == null || channel.groupTitle == groupTitle) {
          channels.add(channel);
        }
        currentExtInf = null;
      }
    }

    return channels;
  }

  @override
  List<M3uChannel> searchChannels(String content, {required String query}) {
    final allChannels = parse(content);
    final queryLower = query.toLowerCase();

    return allChannels.where((channel) {
      return channel.name.toLowerCase().contains(queryLower) ||
          (channel.groupTitle?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }
}