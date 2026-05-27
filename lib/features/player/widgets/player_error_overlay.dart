import 'package:flutter/material.dart';

class PlayerErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onSelectSource;

  const PlayerErrorOverlay({
    super.key,
    required this.message,
    this.onRetry,
    this.onSelectSource,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onRetry != null)
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('重試'),
                  ),
                const SizedBox(width: 16),
                if (onSelectSource != null)
                  OutlinedButton(
                    onPressed: onSelectSource,
                    child: const Text('選擇來源'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}