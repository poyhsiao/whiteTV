// Sprint 7.1 — Unified Dio provider (canonical location: lib/core/api/)
// 各模組透過 ref.watch(dioProvider) 取得共享 Dio instance。
// Production 用 dioProvider.overrideWithValue(...) 提供設定 (baseUrl、timeouts)
// 測試可在 ProviderScope 覆寫,或接受預設值。

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared Dio instance for downloads + favorites + any HTTP-using service.
/// Defaults to a plain `Dio()` so legacy callers compile/run; production wiring
/// in lib/main.dart overrides with configured Dio (timeouts, baseUrl).
/// Tests that don't need HTTP behavior can ignore; tests that do should
/// override with a mock adapter-backed Dio.
final dioProvider = Provider<Dio>((ref) => Dio());