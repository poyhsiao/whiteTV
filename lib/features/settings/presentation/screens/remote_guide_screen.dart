import 'package:flutter/material.dart';

class RemoteGuideScreen extends StatelessWidget {
  const RemoteGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('遙控器操作說明')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            '全域按鍵',
            ['OK:確認', 'Back:返回', 'Home:首頁', 'D-pad:導航'],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '播放中',
            [
              'OK:確認',
              '上/下:音量',
              '左/右:進度',
              'Play/Pause:播放/暫停',
              '快進/快退:10秒',
              '長按快進:5x/10x/20x加速',
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '首頁',
            ['上/下:切換分類列', '左/右:卡片導航', 'OK:進入詳情'],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '詳情頁',
            ['左/右:選擇集數', '上/下:滾動說明', 'OK:播放當前選擇'],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '搜尋',
            ['語音:語音輸入', 'OK:開始搜尋'],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '▶ $title',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16),
            child: Text(
              item,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}
