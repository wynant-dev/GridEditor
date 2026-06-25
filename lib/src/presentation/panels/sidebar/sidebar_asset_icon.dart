import 'package:flutter/material.dart';

import 'sidebar_theme.dart';

/// Renders a catalog or tool icon from assets with consistent sizing and tint.
class SidebarAssetIcon extends StatelessWidget {
  const SidebarAssetIcon({
    super.key,
    required this.assetPath,
    this.selected = false,
    this.fallbackIcon,
    this.light = false,
  });

  final String assetPath;
  final bool selected;
  final IconData? fallbackIcon;
  /// When true, tints the asset white (e.g. logo on blue header).
  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light
        ? Colors.white
        : (selected ? SidebarTheme.selectedIconColor : SidebarTheme.iconColor);

    return Image.asset(
      assetPath,
      width: SidebarTheme.iconSize,
      height: SidebarTheme.iconSize,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, _, _) => Icon(
        fallbackIcon ?? Icons.image_outlined,
        size: SidebarTheme.iconSize,
        color: light
            ? Colors.white
            : (selected
                ? SidebarTheme.selectedIconColor
                : SidebarTheme.iconColor),
      ),
    );
  }
}
