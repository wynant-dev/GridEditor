import 'package:flutter/material.dart';

import 'sidebar_theme.dart';

/// Pill-shaped floating container with shadow for the sidebar.
class SidebarContainer extends StatelessWidget {
  const SidebarContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SidebarTheme.width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: SidebarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(SidebarTheme.borderRadius),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: SidebarTheme.floatingShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
