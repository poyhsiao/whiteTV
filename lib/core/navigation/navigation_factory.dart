import 'package:flutter/material.dart';

import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/device_utils.dart';

/// 導航工廠
/// 根據設備類型返回對應的導航組件
///
/// 用法:
/// ```dart
/// NavigationFactory.getNavigation(
///   context,
///   tabletNav: const SidebarNavigation(),
///   desktopNav: const DesktopDockNavigation(),
///   mobileNav: const MobileNavigation(),
///   tvNav: const TVNavigation(),
/// );
/// ```
class NavigationFactory {
  NavigationFactory._();

  /// 根據設備類型獲取對應的導航組件
  ///
  /// - [tabletNav] - Tablet 設備使用的導航 (默認: SidebarNavigation)
  /// - [desktopNav] - Desktop 設備使用的導航 (默認: DesktopDockNavigation)
  /// - [mobileNav] - Mobile 設備使用的導航 (默認: 標準底部導航)
  /// - [tvNav] - TV 設備使用的導航 (默認: 使用 mobileNav)
  static Widget getNavigation(
    BuildContext context, {
    Widget? tabletNav,
    Widget? desktopNav,
    Widget? mobileNav,
    Widget? tvNav,
  }) {
    final deviceType = DeviceUtils.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.tablet:
        return tabletNav ?? const SidebarNavigation();
      case DeviceType.desktop:
        return desktopNav ?? const DesktopDockNavigation();
      case DeviceType.tv:
        return tvNav ?? mobileNav ?? const MobileNavigation();
      case DeviceType.mobile:
        return mobileNav ?? const MobileNavigation();
    }
  }
}

/// 側邊欄導航 (用於 Tablet)
class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('首頁'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text('搜尋'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite),
                label: Text('收藏'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('設定'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          const Expanded(child: Placeholder()),
        ],
      ),
    );
  }
}

/// 桌面 Dock 導航 (用於 Desktop)
class DesktopDockNavigation extends StatelessWidget {
  const DesktopDockNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Placeholder(),
    );
  }
}

/// 標準底部導航 (用於 Mobile)
class MobileNavigation extends StatelessWidget {
  const MobileNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Placeholder(),
    );
  }
}

/// TV 導航 (用於 TV)
class TVNavigation extends StatelessWidget {
  const TVNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Placeholder(),
    );
  }
}