import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/settings_store.dart';

class SourceBlocklistTile extends ConsumerWidget {
  const SourceBlocklistTile({super.key});

  static const _availableSources = ['量子資源', '非凡資源', '雲播資源', '極速資源'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final blockedSources = settings.blockedSources;

    return Column(
      children: _availableSources.map((source) {
        final isBlocked = blockedSources.contains(source);
        return CheckboxListTile(
          title: Text(source),
          value: isBlocked,
          onChanged: (value) {
            ref
                .read(settingsStoreProvider.notifier)
                .toggleBlockedSource(source);
          },
        );
      }).toList(),
    );
  }
}
