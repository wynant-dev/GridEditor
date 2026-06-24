import 'dart:convert';

import 'item.dart';

/// A named collection of placeable item definitions (user-created or loaded from JSON).
class Catalog {
  const Catalog({
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

  Catalog copyWith({
    String? id,
    String? name,
    List<CatalogItem>? items,
  }) {
    return Catalog(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }

  Catalog addItem(CatalogItem item) {
    return copyWith(items: [...items, item]);
  }

  Catalog updateItem(CatalogItem item) {
    return copyWith(
      items: [
        for (final existing in items)
          if (existing.id == item.id) item else existing,
      ],
    );
  }

  Catalog removeItem(String itemId) {
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

  factory Catalog.fromJson(String source) {
    return Catalog.fromJsonMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  factory Catalog.fromJsonMap(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return Catalog(
      id: json['id'] as String,
      name: json['name'] as String,
      items: [
        for (final entry in rawItems)
          CatalogItem.fromJson(entry as Map<String, dynamic>),
      ],
    );
  }
}
