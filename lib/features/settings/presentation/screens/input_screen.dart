import 'package:flutter/material.dart';
import 'package:white_tv/shared/widgets/qr_input_widget.dart';
import 'package:white_tv/core/services/input_service.dart';

class InputScreen extends StatefulWidget {
  final String title;
  final String? initialValue;
  final void Function(String) onComplete;

  const InputScreen({
    super.key,
    required this.title,
    this.initialValue,
    required this.onComplete,
  });

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  late InputService _inputService;
  String _currentInput = '';

  @override
  void initState() {
    super.initState();
    _inputService = InputService();
    _inputService.setOnInputComplete(widget.onComplete);
    _startServer();
  }

  Future<void> _startServer() async {
    await _inputService.startServer();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _inputService.stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_inputService.isRunning)
            TextButton(
              onPressed: () => widget.onComplete(_currentInput),
              child: const Text(
                '完成',
                style: TextStyle(color: Color(0xFFFFB347)),
              ),
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_inputService.isRunning)
              const CircularProgressIndicator(color: Color(0xFFFFB347))
            else ...[
              QrInputWidget(
                url: _inputService.getQrCodeUrl(),
                onToggle: () => _showRemoteInputDialog(),
              ),
              const SizedBox(height: 32),
              _buildInputDisplay(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.text_fields, color: Colors.white70),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _currentInput.isEmpty ? '等待輸入...' : _currentInput,
              style: TextStyle(
                color: _currentInput.isEmpty ? Colors.white38 : Colors.white,
                fontSize: 18,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoteInputDialog() {
    showDialog(
      context: context,
      builder: (context) => _RemoteInputDialog(
        onSubmit: (text) {
          _currentInput = text;
          widget.onComplete(text);
        },
      ),
    );
  }
}

class _RemoteInputDialog extends StatefulWidget {
  final void Function(String) onSubmit;

  const _RemoteInputDialog({required this.onSubmit});

  @override
  State<_RemoteInputDialog> createState() => _RemoteInputDialogState();
}

class _RemoteInputDialogState extends State<_RemoteInputDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: const Text('輸入文字', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _controller,
        style: const TextStyle(color: Colors.white),
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '輸入...',
          hintStyle: TextStyle(color: Colors.white38),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            widget.onSubmit(_controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('確認'),
        ),
      ],
    );
  }
}