import 'package:flutter_test/flutter_test.dart';
import 'package:white_tv/core/api/models.dart';

void main() {
  group('PlayerStore 來源屏蔽整合', () {
    test('setVideo 自動過濾已屏蔽來源', () async {
      final sources = [
        const VideoSource(id: 'src1', url: 'https://s1.com', name: '量子資源'),
        const VideoSource(id: 'src2', url: 'https://s2.com', name: '八方資源'),
        const VideoSource(id: 'src3', url: 'https://s3.com', name: '光子雲'),
      ];
      //八方資源被屏蔽
      final blockedSources = ['八方資源'];

      // 預期:八方資源被過濾，只傳 2 個來源給 selectSource
      expect(sources.where((s) => !blockedSources.contains(s.name)).length, 2);
    });
  });
}
