import 'package:flutter/material.dart';

import 'sidebar_theme.dart';

/// Floating rectangular panel shown beside the sidebar for submenu content.
class SidebarSubmenuPanel extends StatelessWidget {
  const SidebarSubmenuPanel({super.key, required this.children});

  final List<Widget> children;

  static const _radius = 10.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SidebarTheme.submenuBackgroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
        side: BorderSide(
          color: SidebarTheme.submenuBorderColor.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
