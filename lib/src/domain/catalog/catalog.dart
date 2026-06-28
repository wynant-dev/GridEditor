import 'dart:convert';

import 'category.dart';
import 'floor.dart';
import 'item.dart';
import 'sticker.dart';

/// A named collection of placeable item definitions (user-created or loaded from JSON).
class Catalog {
  const Catalog({
    required this.id,
    required this.name,
    this.categories = const [],
    this.items = const [],
    this.floors = const [],
    this.stickers = const [],
  });

  final String id;
  final String name;
  final List<CatalogCategory> categories;
  final List<CatalogItem> items;
  final List<CatalogFloor> floors;
  final List<CatalogSticker> stickers;

  CatalogCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  CatalogItem? itemById(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  CatalogFloor? floorById(String id) {
    for (final floor in floors) {
      if (floor.id == id) return floor;
    }
    return null;
  }

  CatalogSticker? stickerById(String id) {
    for (final sticker in stickers) {
      if (sticker.id == id) return sticker;
    }
    return null;
  }

  List<CatalogItem> itemsInCategory(String categoryId) {
    return [
      for (final item in items)
        if (item.categoryId == categoryId) item,
    ];
  }

  Catalog copyWith({
    String? id,
    String? name,
    List<CatalogCategory>? categories,
    List<CatalogItem>? items,
    List<CatalogFloor>? floors,
    List<CatalogSticker>? stickers,
  }) {
    return Catalog(
      id: id ?? this.id,
      name: name ?? this.name,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      floors: floors ?? this.floors,
      stickers: stickers ?? this.stickers,
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
    if (categories.isNotEmpty)
      'categories': [for (final category in categories) category.toJson()],
    'items': [for (final item in items) item.toJson()],
    if (floors.isNotEmpty)
      'floors': [for (final floor in floors) floor.toJson()],
    if (stickers.isNotEmpty)
      'stickers': [for (final sticker in stickers) sticker.toJson()],
  };

  factory Catalog.fromJson(String source) {
    return Catalog.fromJsonMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  factory Catalog.fromJsonMap(Map<String, dynamic> json) {
    final rawCategories = json['categories'] as List<dynamic>? ?? [];
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawFloors = json['floors'] as List<dynamic>? ?? [];
    final rawStickers = json['stickers'] as List<dynamic>? ?? [];
    return Catalog(
      id: json['id'] as String,
      name: json['name'] as String,
      categories: [
        for (final entry in rawCategories)
          CatalogCategory.fromJson(entry as Map<String, dynamic>),
      ],
      items: [
        for (final entry in rawItems)
          CatalogItem.fromJson(entry as Map<String, dynamic>),
      ],
      floors: [
        for (final entry in rawFloors)
          CatalogFloor.fromJson(entry as Map<String, dynamic>),
      ],
      stickers: [
        for (final entry in rawStickers)
          CatalogSticker.fromJson(entry as Map<String, dynamic>),
      ],
    );
  }
}
