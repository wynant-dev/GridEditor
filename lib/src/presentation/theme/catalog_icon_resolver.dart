import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Maps catalog icon names to Material Symbols [IconData].
class CatalogIconResolver {
  const CatalogIconResolver._();

  static IconData resolve(String iconName) {
    return switch (iconName) {
      'apartment' => Symbols.apartment,
      'storefront' => Symbols.storefront,
      'chair' => Symbols.chair,
      'park' => Symbols.park,
      'palette' => Symbols.palette,
      'settings' => Symbols.settings,
      'sticker' => Symbols.sticker,
      _ => Symbols.image,
    };
  }
}
