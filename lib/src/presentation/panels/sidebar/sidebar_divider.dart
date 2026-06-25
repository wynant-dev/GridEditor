import 'package:flutter/material.dart';

import 'sidebar_theme.dart';

/// Thin horizontal rule between sidebar sections.
class SidebarDivider extends StatelessWidget {
  const SidebarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 1,
        color: SidebarTheme.dividerColor,
      ),
    );
  }
}
