import 'package:flutter/material.dart';

import 'sidebar_theme.dart';

/// A single row in the submenu: color swatch and label.
class SidebarSubmenuItem extends StatelessWidget {
  const SidebarSubmenuItem({
    super.key,
    required this.color,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final Color color;
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
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                  ),
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
