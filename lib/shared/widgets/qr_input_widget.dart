import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrInputWidget extends StatelessWidget {
  final String url;
  final VoidCallback onToggle;
  final String? title;

  const QrInputWidget({
    super.key,
    required this.url,
    required this.onToggle,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 16),
        ],
        if (url.isEmpty)
          const CircularProgressIndicator()
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: url,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: onToggle,
          icon: const Icon(Icons.keyboard, color: Colors.white70),
          label: const Text(
            '使用遙控器輸入',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}