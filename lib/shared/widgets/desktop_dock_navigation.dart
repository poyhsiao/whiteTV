import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:white_tv/core/device/device_type.dart';
import 'package:white_tv/core/device/feature_flags.dart';

/// macOS Dock 風格導航組件
/// 僅在 Desktop 設備上啟用
///
/// 參照: docs/superpowers/specs/2026-05-25-ios-macos-design.md
class DesktopDockNavigation extends StatelessWidget {
  const DesktopDockNavigation({
    super.key,
    required this.deviceType,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final DeviceType deviceType;
  final List<DockNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  static const double dockItemWidth = 72.0;
  static const double dockHeight = 80.0;
  static const double indicatorHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    if (!FeatureFlags.enableDockNavigation(deviceType)) {
      return const SizedBox.shrink();
    }

    return _DockNavigationBody(
      items: items,
      selectedIndex: selectedIndex,
      onItemSelected: onItemSelected,
    );
  }
}

class _DockNavigationBody extends StatefulWidget {
  const _DockNavigationBody({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<DockNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  @override
  State<_DockNavigationBody> createState() => _DockNavigationBodyState();
}

class _DockNavigationBodyState extends State<_DockNavigationBody> {
  late int _currentIndex;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(_DockNavigationBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _currentIndex = widget.selectedIndex;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    int? newIndex;

    if (key == LogicalKeyboardKey.tab) {
      newIndex = (_currentIndex + 1) % widget.items.length;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      newIndex = (_currentIndex + 1) % widget.items.length;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      newIndex = (_currentIndex - 1 + widget.items.length) % widget.items.length;
    }

    if (newIndex != null && newIndex != _currentIndex) {
      final index = newIndex;
      setState(() => _currentIndex = index);
      widget.onItemSelected(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DesktopDockNavigation.dockHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.items.length; i++) ...[
              _DockItem(
                item: widget.items[i],
                isSelected: i == _currentIndex,
                onTap: () {
                  setState(() => _currentIndex = i);
                  widget.onItemSelected(i);
                },
              ),
              if (i < widget.items.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _DockItem extends StatefulWidget {
  const _DockItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final DockNavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_DockItem> createState() => _DockItemState();
}

class _DockItemState extends State<_DockItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: DesktopDockNavigation.dockItemWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: DesktopDockNavigation.indicatorHeight,
                width: widget.isSelected ? 32 : 0,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                widget.item.icon,
                size: 28,
                color: widget.isSelected || _isHovered
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 2),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class DockNavigationItem {
  const DockNavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}