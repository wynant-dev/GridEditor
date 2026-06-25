import 'package:flutter/material.dart';

/// Tap regions that share this group do not dismiss the catalog submenu.
final Object catalogSubmenuTapGroup = Object();

/// Shared layout and style tokens for the floating catalog sidebar.
abstract final class SidebarTheme {
  static const double width = 60;
  static const double borderRadius = 30;
  static const double iconSize = 26;
  static const double iconButtonSize = 46;
  static const double historySwatchSize = 22;
  static const double submenuMinWidth = 168;
  static const double submenuOffset = 10;

  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color logoHeaderColor = Color(0xFF1565C0);
  static const Color iconColor = Color(0xFF424242);
  static const Color selectedIconColor = Color(0xFF1565C0);
  static const Color selectedBackgroundColor = Color(0xFFD6E6F7);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color submenuBorderColor = Color(0xFF1565C0);
  static const Color submenuBackgroundColor = Colors.white;

  static List<BoxShadow> get floatingShadow => const [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get submenuShadow => const [
    BoxShadow(
      color: Color(0x1F1565C0),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(2, 2),
    ),
  ];
}
