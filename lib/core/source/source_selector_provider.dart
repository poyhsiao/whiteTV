import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/source/source_metrics.dart';
import 'package:white_tv/core/source/source_selector.dart';

/// SourceSelector 全局 Provider
/// 整个应用共享同一个 SourceSelector 实例

final sourceSelectorProvider = Provider<SourceSelector>((ref) {
  final selector = SourceSelector();

  // 在首次创建时加载屏蔽列表
  _loadBlockedSources(selector);

  return selector;
});

Future<void> _loadBlockedSources(SourceSelector selector) async {
  await selector.loadBlockedSources();
}

/// SourceMetrics 存储 Provider（用于持久化）
final sourceMetricsStorageProvider = Provider<Map<String, SourceMetrics>>((ref) {
  return {};
});