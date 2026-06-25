import 'package:flutter/material.dart';

import 'sidebar_theme.dart';

/// Small color swatch for a history entry with a tooltip showing the name.
class SidebarHistoryButton extends StatelessWidget {
  const SidebarHistoryButton({
    super.key,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  final Color color;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 400),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              width: SidebarTheme.historySwatchSize,
              height: SidebarTheme.historySwatchSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black.withValues(alpha: 0.18)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
