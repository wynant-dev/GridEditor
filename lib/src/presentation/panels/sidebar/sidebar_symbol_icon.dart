import 'package:flutter/material.dart';

import '../../theme/catalog_icon_resolver.dart';
import 'sidebar_theme.dart';

/// Renders a catalog or tool icon from Material Symbols with consistent sizing and tint.
class SidebarSymbolIcon extends StatelessWidget {
  const SidebarSymbolIcon({
    super.key,
    required this.iconName,
    this.selected = false,
    this.light = false,
  });

  final String iconName;
  final bool selected;

  /// When true, tints the icon white (e.g. logo on blue header).
  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light
        ? Colors.white
        : (selected ? SidebarTheme.selectedIconColor : SidebarTheme.iconColor);

    return Icon(
      CatalogIconResolver.resolve(iconName),
      size: SidebarTheme.iconSize,
      color: color,
    );
  }
}
