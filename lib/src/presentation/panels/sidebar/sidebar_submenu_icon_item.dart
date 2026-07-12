import 'package:flutter/material.dart';

import 'sidebar_symbol_icon.dart';
import 'sidebar_theme.dart';

/// A single row in the submenu: icon and label.
class SidebarSubmenuIconItem extends StatelessWidget {
  const SidebarSubmenuIconItem({
    super.key,
    required this.iconName,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final String iconName;
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
                SidebarSymbolIcon(
                  iconName: iconName,
                  selected: selected,
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
