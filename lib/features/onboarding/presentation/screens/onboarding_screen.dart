import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/settings_store.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentStep = 0;
  final _urlController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() => _currentStep++);
  }

  Future<void> _confirmUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _errorMessage = '請輸入伺服器地址');
      return;
    }

    try {
      await ref.read(settingsStoreProvider.notifier).updateLunaTVUrl(url);
      setState(() => _currentStep = 2);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      setState(() => _errorMessage = '保存失敗：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0: return _buildWelcomeStep();
      case 1: return _buildUrlStep();
      case 2: return _buildDoneStep();
      default: return _buildWelcomeStep();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.play_circle, size: 80, color: Colors.amber),
        const SizedBox(height: 24),
        const Text(
          '歡迎使用 whiteTV',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          '享受來自 LunaTV 的精彩影視內容',
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          ),
          child: const Text('開始設定', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildUrlStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '請輸入 LunaTV 伺服器地址',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _urlController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'https://lunatv.example.com',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _confirmUrl,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          ),
          child: const Text('確認', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildDoneStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 80, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          '設定完成！',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          '即將進入首頁...',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }
}
