import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:white_tv/features/settings/settings_store.dart';
import 'package:white_tv/features/settings/widgets/tab_order_editor.dart';
import 'package:white_tv/features/settings/presentation/screens/input_screen.dart';

class GeneralSettingsCard extends ConsumerWidget {
  const GeneralSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLunaTVUrlSection(context, ref, settings),
          const SizedBox(height: 24),
          _buildThemeModeSection(context, ref, settings),
          const SizedBox(height: 24),
          _buildTabOrderSection(),
          const SizedBox(height: 24),
          _buildNavigationSection(context),
        ],
      ),
    );
  }

  Widget _buildLunaTVUrlSection(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LunaTV URL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    settings.lunaTVUrl ?? '未設定',
                    style: TextStyle(
                      color: settings.lunaTVUrl != null
                          ? Colors.white
                          : Colors.white54,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showUrlInputDialog(context, ref),
                  child: const Text('編輯'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSection(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '主題模式',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'dark', label: Text('深色')),
                ButtonSegment(value: 'light', label: Text('淺色')),
                ButtonSegment(value: 'system', label: Text('系統')),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) {
                ref
                    .read(settingsStoreProvider.notifier)
                    .updateThemeMode(selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabOrderSection() {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '標籤順序',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const TabOrderEditor(),
          ],
        ),
      ),
    );
  }

  void _showUrlInputDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsStoreProvider);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InputScreen(
          title: 'LunaTV URL',
          initialValue: settings.lunaTVUrl,
          onComplete: (url) {
            ref.read(settingsStoreProvider.notifier).updateLunaTVUrl(url);
          },
        ),
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.gamepad_outlined, color: Colors.white70),
            title: const Text(
              '遙控器操作說明',
              style: TextStyle(color: Colors.white),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () => context.go('/remote-guide'),
          ),
        ],
      ),
    );
  }
}
