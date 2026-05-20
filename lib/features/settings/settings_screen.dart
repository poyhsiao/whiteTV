import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_tv/features/settings/widgets/general_settings_card.dart';
import 'package:white_tv/features/settings/widgets/account_settings_card.dart';
import 'package:white_tv/features/settings/widgets/playback_settings_card.dart';
import 'package:white_tv/features/settings/widgets/display_settings_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '一般'),
            Tab(text: '帳號'),
            Tab(text: '播放'),
            Tab(text: '顯示'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GeneralSettingsCard(),
          AccountSettingsCard(),
          PlaybackSettingsCard(),
          DisplaySettingsCard(),
        ],
      ),
    );
  }
}
