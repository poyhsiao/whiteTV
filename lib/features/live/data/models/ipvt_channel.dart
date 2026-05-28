import 'package:white_tv/features/live/data/models/m3u_channel.dart';

class IptvChannel {
  final String id;
  final String name;
  final String logo;
  final String url;
  final String? group;

  const IptvChannel({
    required this.id,
    required this.name,
    required this.logo,
    required this.url,
    this.group,
  });

  factory IptvChannel.fromJson(Map<String, dynamic> json) {
    return IptvChannel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
      url: json['url'] as String? ?? '',
      group: json['group'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
    'url': url,
    'group': group,
  };

  /// Convert to M3uChannel (internal model)
  M3uChannel toM3uChannel() {
    return M3uChannel(
      name: name,
      url: url,
      logoUrl: logo.isNotEmpty ? logo : null,
      groupTitle: group,
      tvgId: id,
    );
  }
}
