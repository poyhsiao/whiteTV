// Default fallback implementations for SettingsStorageService abstract methods.
import 'settings_storage_service.dart';

mixin SettingsStorageServiceFallbacks implements SettingsStorageService {
  @override
  Future<void> saveTimeshiftBufferDuration(int minutes) async {}

  @override
  Future<int> getTimeshiftBufferDuration() async => 30;
}