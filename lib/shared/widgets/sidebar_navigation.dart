import 'package:flutter/material.dart';
import 'package:white_tv/core/device/device_type.dart';

/// 側邊欄導航項目數據類
class NavigationItemData {
  final IconData icon;
  final String label;
  final String route;
  final VoidCallback? onTap;

  const NavigationItemData({
    required this.icon,
    required this.label,
    required this.route,
    this.onTap,
  });
}

/// 側邊欄導航組件 - 專為 iPad 平板設備設計
/// 支持折疊/展開、拖拽調整寬度、鼠標懸停效果
class SidebarNavigation extends StatefulWidget {
  final DeviceType deviceType;
  final List<NavigationItemData> children;
  final double width;
  final double minWidth;
  final double maxWidth;
  final bool initialCollapsed;
  final Color? backgroundColor;
  final Color? selectedColor;
  final ValueChanged<bool>? onCollapsedChanged;

  const SidebarNavigation({
    super.key,
    required this.deviceType,
    required this.children,
    this.width = 250.0,
    this.minWidth = 100.0,
    this.maxWidth = 400.0,
    this.initialCollapsed = false,
    this.backgroundColor,
    this.selectedColor,
    this.onCollapsedChanged,
  });

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation> {
  late bool _isCollapsed;
  late double _currentWidth;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initialCollapsed;
    _currentWidth = widget.width;
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
    widget.onCollapsedChanged?.call(_isCollapsed);
  }

  void _handleHover(bool isHovering) {
    if (!_isCollapsed) {
      setState(() {
        _isHovering = isHovering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: _isCollapsed ? _toggleCollapse : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _isCollapsed ? widget.minWidth : _currentWidth,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? const Color(0xFF1A1A2E),
            boxShadow: _isHovering || _isCollapsed
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 0),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              // Header with collapse button
              _buildHeader(),
              // Navigation items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.children.length,
                  itemBuilder: (context, index) {
                    return _SidebarNavigationItem(
                      data: widget.children[index],
                      isCollapsed: _isCollapsed,
                      isHovering: _isHovering,
                    );
                  },
                ),
              ),
              // Resize handle
              if (!_isCollapsed) _buildResizeHandle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
              color: Colors.white70,
            ),
            onPressed: _toggleCollapse,
            tooltip: _isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
          ),
          if (!_isCollapsed)
            const Expanded(
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResizeHandle() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          final newWidth = _currentWidth - details.delta.dx;
          _currentWidth = newWidth.clamp(widget.minWidth, widget.maxWidth);
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: double.infinity,
          height: 8,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 內部導航項目組件
class _SidebarNavigationItem extends StatefulWidget {
  final NavigationItemData data;
  final bool isCollapsed;
  final bool isHovering;

  const _SidebarNavigationItem({
    required this.data,
    required this.isCollapsed,
    required this.isHovering,
  });

  @override
  State<_SidebarNavigationItem> createState() => _SidebarNavigationItemState();
}

class _SidebarNavigationItemState extends State<_SidebarNavigationItem> {
  bool _isItemHovering = false;

  @override
  Widget build(BuildContext context) {
    final showHoverEffect = _isItemHovering || widget.isHovering;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isItemHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isItemHovering = false;
        });
      },
      child: GestureDetector(
        onTap: widget.data.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 8 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: showHoverEffect
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: widget.isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                widget.data.icon,
                color: showHoverEffect ? Colors.white : Colors.white70,
                size: 24,
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.data.label,
                    style: TextStyle(
                      color: showHoverEffect ? Colors.white : Colors.white70,
                      fontSize: 16,
                      fontWeight: showHoverEffect ? FontWeight.w500 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 單個導航項目組件（用於直接嵌入到其他佈局中）
class NavigationItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final VoidCallback? onTap;

  const NavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    this.onTap,
  });

  @override
  State<NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap ?? () {
          debugPrint('Navigate to: ${widget.route}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovering ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: _isHovering ? Colors.white : Colors.white70,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: _isHovering ? Colors.white : Colors.white70,
                    fontSize: 16,
                    fontWeight: _isHovering ? FontWeight.w500 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}