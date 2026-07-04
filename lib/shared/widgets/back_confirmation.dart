// TV 全域 Back 鍵確認 widget
// 規範: docs/spec/UI_UX.md §15.1
// 行為: 第一次按 Back 顯示 SnackBar; window 內再按第二次觸發 onConfirmExit
//
// 呼叫者: lib/features/home/home_screen.dart
//         其他需要 Back 確認的 root page
//
// ponytail: 簡單 PopScope + Timer; 多策略時 (不同頁面 / 不同 timeout) 再抽 manager

import 'dart:async';

import 'package:flutter/material.dart';

class BackConfirmation extends StatefulWidget {
  const BackConfirmation({
    super.key,
    required this.child,
    required this.onConfirmExit,
    this.message = '再按一次退出 whiteTV',
    this.window = const Duration(seconds: 2),
  });

  final Widget child;

  /// 第二次按 Back (window 內) 時觸發
  final VoidCallback onConfirmExit;

  final String message;

  /// 兩次按鍵的允許間隔
  final Duration window;

  @override
  State<BackConfirmation> createState() => _BackConfirmationState();
}

class _BackConfirmationState extends State<BackConfirmation> {
  Timer? _resetTimer;
  bool _waitingForSecond = false;
  bool _exitRequested = false;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _onPop(bool didPop) {
    if (_exitRequested) return;

    if (_waitingForSecond) {
      _resetTimer?.cancel();
      _waitingForSecond = false;
      _exitRequested = true;
      widget.onConfirmExit();
      return;
    }

    _waitingForSecond = true;
    _resetTimer?.cancel();
    _resetTimer = Timer(widget.window, () {
      _waitingForSecond = false;
    });

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(widget.message),
          duration: widget.window,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _onPop(didPop),
      child: widget.child,
    );
  }
}
