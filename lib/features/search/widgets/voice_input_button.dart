import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:white_tv/features/search/services/voice_input_service.dart';
import 'package:white_tv/core/device/device_utils.dart';

/// TV 遙控器麥克風鍵整合在 VoiceInputButton 內（UI_UX.md §16）
class VoiceInputButton extends StatefulWidget {
  final void Function(String) onResult;
  final VoiceInputService? service;

  const VoiceInputButton({
    super.key,
    required this.onResult,
    this.service,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  late final VoiceInputService _service;
  StreamSubscription<String>? _subscription;
  late final FocusNode _focusNode;
  // ponytail: cache isTV to avoid context access during key events
  bool _isTV = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TVVoiceInputService();
    _subscription = _service.onResult.listen((result) {
      widget.onResult(result);
    });
    // skipTraversal=true prevents this button from stealing focus during D-pad navigation
    _focusNode = FocusNode(skipTraversal: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isTV = DeviceUtils.isTV(context);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  /// 啟動監聽（供外部或遙控器觸發）
  Future<void> startListening() async {
    if (!mounted) return;
    if (_service.isListening) return;
    await _service.startListening();
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (_service.isListening) {
      await _service.stopListening();
    } else {
      await _service.startListening();
    }
    if (mounted) setState(() {});
  }

  /// 處理 TV 遙控器麥克風鍵（UI_UX.md §16.3）
  /// ponytail: audioVolumeMute is the typical mapping; verify with device maker
  void _handleTVRemoteKey(KeyEvent event) {
    if (!_isTV) return;
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.audioVolumeMute) {
      _toggleListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: false,
      includeSemantics: false,
      onKeyEvent: _handleTVRemoteKey,
      child: IconButton(
        icon: Icon(
          _service.isListening ? Icons.mic : Icons.mic_none,
        ),
        color: _service.isListening ? Colors.red : Colors.white,
        onPressed: _toggleListening,
        tooltip: _isTV ? '按遙控器麥克風鍵或點擊說話' : '語音輸入',
      ),
    );
  }
}
