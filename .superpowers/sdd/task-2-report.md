# Task 2 Report: Settings Page Timeshift Buffer Duration UI

## Objective
Add RadioListTile UI for timeshift buffer duration selection (15/30/60 minutes) to the Settings page.

## Implementation

### File Modified
`lib/features/settings/widgets/playback_settings_card.dart`

### Changes Made
Added `_buildTimeshiftBufferSection` method and integrated it into `PlaybackSettingsCard.build()`:

```dart
Widget _buildTimeshiftBufferSection(WidgetRef ref, SettingsState settings) {
  return Card(
    color: Colors.white.withValues(alpha: 0.1),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '時移緩衝',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          RadioListTile<int>(
            title: const Text('15 分鐘', style: TextStyle(color: Colors.white)),
            value: 15,
            groupValue: settings.timeshiftBufferDuration,
            onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
          ),
          RadioListTile<int>(
            title: const Text('30 分鐘', style: TextStyle(color: Colors.white)),
            value: 30,
            groupValue: settings.timeshiftBufferDuration,
            onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
          ),
          RadioListTile<int>(
            title: const Text('60 分鐘', style: TextStyle(color: Colors.white)),
            value: 60,
            groupValue: settings.timeshiftBufferDuration,
            onChanged: (v) => ref.read(settingsStoreProvider.notifier).updateTimeshiftBufferDuration(v!),
          ),
        ],
      ),
    ),
  );
}
```

### Integration
Section added as 5th item in `PlaybackSettingsCard`, after `_buildSourceBlocklistSection()`.

### Analysis
`flutter analyze` returned only info-level deprecation warnings for RadioListTile's `groupValue` and `onChanged` (deprecated in Flutter 3.32). No errors.

## Commit
- SHA: `287c30442c5cb013c20beba3f86354792ad7b5bf`
- Message: `feat: add timeshift buffer duration RadioListTile to playback settings`
