/// 來源指標模型
/// 用於追蹤每個來源的歷史表現
library;

class SourceMetrics {
  final String sourceId;
  int successCount;
  int failCount;
  int totalLatency;
  DateTime lastTested;

  SourceMetrics({
    required this.sourceId,
    this.successCount = 0,
    this.failCount = 0,
    this.totalLatency = 0,
    DateTime? lastTested,
  }) : lastTested = lastTested ?? DateTime.now();

  /// 成功率 = 成功次數 / 總次數
  double get successRate {
    final total = successCount + failCount;
    if (total == 0) return 1.0; // 無記錄時默認 100%
    return successCount / total;
  }

  /// 平均延遲
  int get avgLatency {
    if (successCount == 0) return 0;
    return totalLatency ~/ successCount;
  }

  /// 記錄成功
  void recordSuccess({required int latency}) {
    successCount++;
    totalLatency += latency;
    lastTested = DateTime.now();
  }

  /// 記錄失敗
  void recordFailure() {
    failCount++;
    lastTested = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'sourceId': sourceId,
        'successCount': successCount,
        'failCount': failCount,
        'totalLatency': totalLatency,
        'lastTested': lastTested.toIso8601String(),
      };

  factory SourceMetrics.fromJson(Map<String, dynamic> json) {
    return SourceMetrics(
      sourceId: json['sourceId'] as String,
      successCount: json['successCount'] as int? ?? 0,
      failCount: json['failCount'] as int? ?? 0,
      totalLatency: json['totalLatency'] as int? ?? 0,
      lastTested: json['lastTested'] != null
          ? DateTime.parse(json['lastTested'] as String)
          : DateTime.now(),
    );
  }
}