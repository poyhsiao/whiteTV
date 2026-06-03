import 'package:flutter/material.dart';

class PinDialog extends StatefulWidget {
  final String title;
  final int pinLength;

  const PinDialog({
    super.key,
    this.title = '輸入PIN碼',
    this.pinLength = 4,
  });

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final List<String> _digits = [];

  void _onDigit(String digit) {
    if (_digits.length >= widget.pinLength) return;
    setState(() => _digits.add(digit));
    if (_digits.length == widget.pinLength) {
      Navigator.of(context).pop(_digits.join());
    }
  }

  void _onDelete() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.pinLength, (i) {
              return Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _digits.length
                      ? Colors.amber
                      : Colors.white24,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          ..._buildKeypadRows(),
        ],
      ),
    );
  }

  List<Widget> _buildKeypadRows() {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return rows.map((row) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row.map((key) {
          if (key == 'del') {
            return _buildButton(
              const Icon(Icons.backspace),
              () => _onDelete(),
            );
          }
          if (key.isEmpty) {
            return const SizedBox(width: 64, height: 64);
          }
          return _buildButton(
            Text(key, style: const TextStyle(fontSize: 24, color: Colors.white)),
            () => _onDigit(key),
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildButton(Widget child, VoidCallback onTap) {
    return Container(
      width: 64,
      height: 64,
      margin: const EdgeInsets.all(4),
      child: MaterialButton(
        onPressed: onTap,
        color: Colors.white.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
