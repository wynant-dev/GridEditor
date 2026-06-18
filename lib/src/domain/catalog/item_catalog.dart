import 'dart:convert';

import 'catalog_item.dart';

/// A named collection of item definitions (user-created or loaded from JSON).
class ItemCatalog {
  const ItemCatalog({
    required this.id,
    required this.name,
    this.items = const [],
  });

  final String id;
  final String name;
  final List<CatalogItem> items;

  CatalogItem? itemById(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  ItemCatalog copyWith({
    String? id,
    String? name,
    List<CatalogItem>? items,
  }) {
    return ItemCatalog(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  ItemCatalog addItem(CatalogItem item) {
    return copyWith(items: [...items, item]);
  }

  ItemCatalog updateItem(CatalogItem item) {
    return copyWith(
      items: [
        for (final existing in items)
          if (existing.id == item.id) item else existing,
      ],
    );
  }

  ItemCatalog removeItem(String itemId) {
    return copyWith(
      items: items.where((item) => item.id != itemId).toList(),
    );
  }

  String toJson() => jsonEncode(toJsonMap());

  Map<String, dynamic> toJsonMap() => {
    'id': id,
    'name': name,
    'items': [for (final item in items) item.toJson()],
  };

  factory ItemCatalog.fromJson(String source) {
    return ItemCatalog.fromJsonMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  factory ItemCatalog.fromJsonMap(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ItemCatalog(
      id: json['id'] as String,
      name: json['name'] as String,
      items: [
        for (final entry in rawItems)
          CatalogItem.fromJson(entry as Map<String, dynamic>),
      ],
    );
  }
}
