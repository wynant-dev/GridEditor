import 'package:flutter/material.dart';

import '../../domain/catalog/floor.dart';
import '../../domain/catalog/item.dart';

class CatalogColorResolver {
  CatalogColorResolver._();

  static Color fromItem(CatalogItem item) {
    return _parse(item.color) ?? Colors.blueGrey.shade200;
  }

  static Color fromFloor(CatalogFloor floor) {
    return _parse(floor.color) ?? Colors.blueGrey.shade200;
  }

  static Color? _parse(String? value) {
    if (value == null || value.isEmpty) return null;
    final hex = value.startsWith('#') ? value.substring(1) : value;
    if (hex.length == 6) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) return Color(0xFF000000 | parsed);
    }
    return null;
  }
}
