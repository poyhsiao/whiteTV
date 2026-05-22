import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/auth_store.dart';
import 'package:white_tv/shared/widgets/qr_input_widget.dart';
import 'package:white_tv/core/services/input_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final void Function(bool success) onLoginComplete;
  final bool showQrInput;

  const LoginScreen({
    super.key,
    required this.onLoginComplete,
    this.showQrInput = true,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final InputService _inputService = InputService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _inputService.setOnInputComplete(_handlePhoneInput);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _inputService.stopServer();
    super.dispose();
  }

  void _handlePhoneInput(String text) {
    // Parse input as username:password
    final parts = text.split(':');
    if (parts.length >= 2) {
      _usernameController.text = parts[0];
      _passwordController.text = parts[1];
      _performLogin();
    }
  }

  Future<void> _performLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authStore = ref.read(authStoreProvider.notifier);
    final success = await authStore.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!success) {
          final authState = ref.read(authStoreProvider);
          _errorMessage = authState.error ?? '登入失敗';
        }
      });

      if (success) {
        widget.onLoginComplete(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '登入',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.showQrInput) ...[
                _buildQrInputSection(),
                const SizedBox(height: 32),
                const Divider(color: Colors.white24),
                const SizedBox(height: 32),
                const Text(
                  '或使用遙控器輸入',
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 16),
              ],
              _buildLoginForm(),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrInputSection() {
    return FutureBuilder<bool>(
      future: _inputService.startServer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.data == true) {
          return QrInputWidget(
            url: _inputService.getQrCodeUrl(),
            title: '掃描以輸入帳密',
            onToggle: () {},
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              Icon(Icons.wifi_off, color: Colors.orange, size: 48),
              SizedBox(height: 8),
              Text(
                '無法使用手機輸入',
                style: TextStyle(color: Colors.orange),
              ),
              Text(
                '請確認電視和手機連接同一 WiFi',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '帳號',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            obscureText: true,
            decoration: InputDecoration(
              labelText: '密碼',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _performLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB347),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('登入', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}