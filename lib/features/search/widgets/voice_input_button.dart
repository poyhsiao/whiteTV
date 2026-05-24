import 'dart:async';

import 'package:flutter/material.dart';
import 'package:white_tv/features/search/services/voice_input_service.dart';

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

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TVVoiceInputService();
    _subscription = _service.onResult.listen((result) {
      widget.onResult(result);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_service.isListening) {
      await _service.stopListening();
    } else {
      await _service.startListening();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _service.isListening ? Icons.mic : Icons.mic_none,
      ),
      color: _service.isListening ? Colors.red : Colors.white,
      onPressed: _toggleListening,
    );
  }
}