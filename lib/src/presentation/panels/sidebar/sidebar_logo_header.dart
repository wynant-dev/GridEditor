import 'package:flutter/material.dart';

import 'sidebar_asset_icon.dart';
import 'sidebar_theme.dart';

/// Blue header with the app logo at the top of the sidebar.
class SidebarLogoHeader extends StatelessWidget {
  const SidebarLogoHeader({super.key, this.logoAssetPath = 'assets/icons/logo.png'});

  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SidebarTheme.width,
      decoration: const BoxDecoration(
        color: SidebarTheme.logoHeaderColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(SidebarTheme.borderRadius)),
      ),
      alignment: Alignment.center,
      child: SidebarAssetIcon(
        assetPath: logoAssetPath,
        light: true,
        fallbackIcon: Icons.grid_view_rounded,
      ),
    );
  }
}
