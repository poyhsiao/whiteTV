// ignore_for_file: use_build_context_synchronously
// (showDialog returns before widget tree is disposed; mounted guards are in place)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/core/services/parental_control_service.dart';
import 'package:white_tv/shared/widgets/pin_dialog.dart';

final parentalControlStateProvider = FutureProvider<ParentalControlState>((ref) async {
  final service = ref.watch(parentalControlServiceProvider);
  return service.getState();
});

class ParentalControlCard extends ConsumerStatefulWidget {
  const ParentalControlCard({super.key});

  @override
  ConsumerState<ParentalControlCard> createState() => _ParentalControlCardState();
}

class _ParentalControlCardState extends ConsumerState<ParentalControlCard> {
  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(parentalControlStateProvider);

    return stateAsync.when(
      data: (state) => Card(
        color: Colors.white.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '家長鎖設定',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (!state.hasPin) ...[
                ElevatedButton(
                  onPressed: () => _showSetPinDialog(context),
                  child: const Text('設定PIN碼'),
                ),
              ] else ...[
                SwitchListTile(
                  title: const Text(
                    '開啟家長鎖',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    '開啟後需輸入PIN碼才能觀看成人內容',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  value: state.enabled,
                  onChanged: (value) async {
                    await ref.read(parentalControlServiceProvider).toggleEnabled(value);
                    ref.invalidate(parentalControlStateProvider);
                  },
                ),
                TextButton(
                  onPressed: () => _showChangePinDialog(context),
                  child: const Text('變更PIN碼'),
                ),
              ],
              if (state.isLocked)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'PIN已鎖定，請等待60秒後重試',
                    style: TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
      loading: () => Card(
        color: Colors.white.withValues(alpha: 0.1),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Card(
        child: Center(child: Text('錯誤: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Future<void> _showSetPinDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const PinDialog(title: '設定PIN碼'),
    );
    if (result != null) {
      await ref.read(parentalControlServiceProvider).setPin(result);
      ref.invalidate(parentalControlStateProvider);
    }
  }

  Future<void> _showChangePinDialog(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final oldPin = await showDialog<String>(
      context: context,
      builder: (_) => const PinDialog(title: '輸入舊PIN碼'),
    );
    if (oldPin == null || !mounted) return;

    final service = ref.read(parentalControlServiceProvider);
    final valid = await service.verifyPin(oldPin);
    if (!valid) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('PIN碼錯誤')),
      );
      return;
    }

    final newPin = await showDialog<String>(
      context: context,
      builder: (_) => const PinDialog(title: '設定新PIN碼'),
    );
    if (newPin != null) {
      await service.setPin(newPin);
      ref.invalidate(parentalControlStateProvider);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('PIN碼已更新')),
      );
    }
  }
}
