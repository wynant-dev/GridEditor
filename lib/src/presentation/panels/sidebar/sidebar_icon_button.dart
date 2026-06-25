import 'package:flutter/material.dart';

import 'sidebar_theme.dart';

/// Tappable sidebar icon with an optional selected-state circle background.
class SidebarIconButton extends StatelessWidget {
  const SidebarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.selected = false,
    this.tooltip,
    this.link,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final bool selected;
  final String? tooltip;
  final LayerLink? link;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        splashColor: SidebarTheme.selectedIconColor.withValues(alpha: 0.12),
        highlightColor: SidebarTheme.selectedIconColor.withValues(alpha: 0.08),
        child: SizedBox(
          width: SidebarTheme.iconButtonSize,
          height: SidebarTheme.iconButtonSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: selected ? SidebarTheme.iconButtonSize - 6 : 0,
                height: selected ? SidebarTheme.iconButtonSize - 6 : 0,
                decoration: selected
                    ? BoxDecoration(
                        color: SidebarTheme.selectedBackgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SidebarTheme.selectedIconColor.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      )
                    : null,
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: selected ? 1.05 : 1,
                child: icon,
              ),
            ],
          ),
        ),
      ),
    );

    final linked = link != null
        ? CompositedTransformTarget(link: link!, child: button)
        : button;

    if (tooltip == null) return linked;
    return Tooltip(
      message: tooltip!,
      waitDuration: const Duration(milliseconds: 400),
      child: linked,
    );
  }
}
