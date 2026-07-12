import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'sidebar_theme.dart';

/// Blue header with the app logo at the top of the sidebar.
class SidebarLogoHeader extends StatelessWidget {
  const SidebarLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SidebarTheme.width,
      decoration: const BoxDecoration(
        color: SidebarTheme.logoHeaderColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(SidebarTheme.borderRadius)),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Symbols.cruelty_free,
        size: SidebarTheme.iconSize,
        color: Colors.white,
      ),
    );
  }
}
