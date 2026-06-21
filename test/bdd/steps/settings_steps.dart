import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:white_tv/core/source/source_selector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Settings BDD', () {
    test('SourceSelector blocks sources', () async {
      SharedPreferences.setMockInitialValues({});
      final selector = SourceSelector();
      await selector.setBlockedSources(['source1']);
      expect(selector.getBlockedSources().contains('source1'), isTrue);
      await selector.setBlockedSources([]);
    });
  });
}
