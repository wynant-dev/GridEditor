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
    this.floors = const [],
    this.stickers = const [],
  });

  final String id;
  final String name;
  final List<CatalogCategory> categories;
  final List<CatalogFloor> floors;
  final List<CatalogSticker> stickers;

  List<CatalogItem> get items => [
    for (final category in categories) ...category.items,
  ];

  CatalogCategory? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  CatalogItem? itemById(String id) {
    for (final category in categories) {
      for (final item in category.items) {
        if (item.id == id) return item;
      }
    }
    return null;
  }

  String? categoryIdForItem(String itemId) {
    for (final category in categories) {
      if (category.items.any((item) => item.id == itemId)) {
        return category.id;
      }
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
    return categoryById(categoryId)?.items ?? const [];
  }

  Catalog copyWith({
    String? id,
    String? name,
    List<CatalogCategory>? categories,
    List<CatalogFloor>? floors,
    List<CatalogSticker>? stickers,
  }) {
    return Catalog(
      id: id ?? this.id,
      name: name ?? this.name,
      categories: categories ?? this.categories,
      floors: floors ?? this.floors,
      stickers: stickers ?? this.stickers,
    );
  }

  Catalog addItem(String categoryId, CatalogItem item) {
    return copyWith(
      categories: [
        for (final category in categories)
          if (category.id == categoryId)
            category.copyWith(items: [...category.items, item])
          else
            category,
      ],
    );
  }

  Catalog updateItem(CatalogItem item) {
    return copyWith(
      categories: [
        for (final category in categories)
          category.copyWith(
            items: [
              for (final existing in category.items)
                if (existing.id == item.id) item else existing,
            ],
          ),
      ],
    );
  }

  Catalog removeItem(String itemId) {
    return copyWith(
      categories: [
        for (final category in categories)
          category.copyWith(
            items: category.items.where((item) => item.id != itemId).toList(),
          ),
      ],
    );
  }

  String toJson() => jsonEncode(toJsonMap());

  Map<String, dynamic> toJsonMap() => {
    'id': id,
    'name': name,
    if (categories.isNotEmpty)
      'categories': [for (final category in categories) category.toJson()],
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
    final rawFloors = json['floors'] as List<dynamic>? ?? [];
    final rawStickers = json['stickers'] as List<dynamic>? ?? [];
    return Catalog(
      id: json['id'] as String,
      name: json['name'] as String,
      categories: [
        for (final entry in rawCategories)
          CatalogCategory.fromJson(entry as Map<String, dynamic>),
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
