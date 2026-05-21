class M3uChannel {
  final String name;
  final String url;
  final String? logoUrl;
  final String? groupTitle;
  final String? tvgId;

  const M3uChannel({
    required this.name,
    required this.url,
    this.logoUrl,
    this.groupTitle,
    this.tvgId,
  });

  factory M3uChannel.parse(String extInfLine, String url) {
    // Parse tvg-id
    final tvgIdMatch = RegExp(r'tvg-id="([^"]*)"').firstMatch(extInfLine);
    final tvgId = tvgIdMatch?.group(1)?.isNotEmpty == true ? tvgIdMatch?.group(1) : null;

    // Parse tvg-name
    final tvgNameMatch = RegExp(r'tvg-name="([^"]*)"').firstMatch(extInfLine);
    final tvgName = tvgNameMatch?.group(1);

    // Parse tvg-logo
    final tvgLogoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(extInfLine);
    final logoUrl = tvgLogoMatch?.group(1)?.isNotEmpty == true ? tvgLogoMatch?.group(1) : null;

    // Parse group-title
    final groupTitleMatch = RegExp(r'group-title="([^"]*)"').firstMatch(extInfLine);
    final groupTitle = groupTitleMatch?.group(1)?.isNotEmpty == true ? groupTitleMatch?.group(1) : null;

    // Extract channel name (after comma)
    final nameMatch = RegExp(r',(.+)$').firstMatch(extInfLine);
    final name = nameMatch?.group(1)?.trim() ?? extInfLine;

    return M3uChannel(
      name: tvgName ?? name,
      url: url,
      logoUrl: logoUrl,
      groupTitle: groupTitle,
      tvgId: tvgId,
    );
  }
}