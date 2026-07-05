// Sprint 8.1 — InputServiceProvider (canonical location: lib/core/services/)
// UI 透過 ref.watch(inputServiceProvider) 取得共享 InputService instance。
// 測試可在 ProviderScope 用 overrideWithValue 注入 SpyInputService。

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/services/input_service.dart';

/// Shared InputService instance. Default returns a fresh `InputService()`
/// (fail-soft). Tests that don't want HttpServer boot override with a spy.
final inputServiceProvider = Provider<InputService>((ref) => InputService());