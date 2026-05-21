class EpgProgram {
  final String id;
  final String channelId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? category;

  const EpgProgram({
    required this.id,
    required this.channelId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.category,
  });

  factory EpgProgram.fromXmlAttributes({
    required String id,
    required String channelId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    String? category,
  }) {
    return EpgProgram(
      id: id,
      channelId: channelId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      category: category,
    );
  }

  Duration get duration => endTime.difference(startTime);

  bool get isCurrentlyActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }
}