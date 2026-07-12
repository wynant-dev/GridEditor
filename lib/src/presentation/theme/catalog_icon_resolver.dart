import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Maps catalog icon names to Material Symbols [IconData].
class CatalogIconResolver {
  const CatalogIconResolver._();

  static IconData resolve(String iconName) {
    return switch (iconName) {
      'apartment' => Symbols.apartment,
      'home' => Symbols.home,
      'domain' => Symbols.domain,
      'account_balance' => Symbols.account_balance,
      'storefront' => Symbols.storefront,
      'restaurant' => Symbols.restaurant,
      'shopping_bag' => Symbols.shopping_bag,
      'store' => Symbols.store,
      'chair' => Symbols.chair,
      'table_restaurant' => Symbols.table_restaurant,
      'weekend' => Symbols.weekend,
      'park' => Symbols.park,
      'grass' => Symbols.grass,
      'local_florist' => Symbols.local_florist,
      'palette' => Symbols.palette,
      'settings' => Symbols.settings,
      'sticker' => Symbols.sticker,
      _ => Symbols.image,
    };
  }
}
