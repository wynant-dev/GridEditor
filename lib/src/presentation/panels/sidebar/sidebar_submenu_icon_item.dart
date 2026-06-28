import 'package:flutter/material.dart';

import 'sidebar_asset_icon.dart';
import 'sidebar_theme.dart';

/// A single row in the submenu: icon and label.
class SidebarSubmenuIconItem extends StatelessWidget {
  const SidebarSubmenuIconItem({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final String iconPath;
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ColoredBox(
          color: selected ? SidebarTheme.selectedBackgroundColor : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                SidebarAssetIcon(
                  assetPath: iconPath,
                  selected: selected,
                  fallbackIcon: Icons.emoji_emotions_outlined,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? SidebarTheme.selectedIconColor
                          : SidebarTheme.iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
