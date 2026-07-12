import 'floor.dart';
import 'item.dart';
import 'sticker.dart';

/// Immutable grid layout state (pure logic, no Flutter).
///
/// Holds three kinds of placed content, each pairing a catalog template with
/// a layout instance:
/// - [CatalogFloor] → [Floor]
/// - [CatalogItem] → [Item]
/// - [CatalogSticker] → [Sticker]
class GridDocument {
  const GridDocument({
    required this.rows,
    required this.cols,
    this.items = const [],
    this.stickers = const [],
    this.floors = const [],
    this.defaultFloorId,
  }) : assert(rows > 0),
       assert(cols > 0);

  final int rows;
  final int cols;
  final List<Item> items;
  final List<Sticker> stickers;

  /// Per-cell overrides; cells not listed use [defaultFloorId] when set.
  final List<Floor> floors;
  final String? defaultFloorId;

  Item? itemById(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Sticker? stickerById(String id) {
    for (final sticker in stickers) {
      if (sticker.id == id) return sticker;
    }
    return null;
  }

  String? floorIdAt(int row, int col) {
    for (final floor in floors) {
      if (floor.row == row && floor.col == col) {
        return floor.catalogFloorId;
      }
    }
    return defaultFloorId;
  }

  GridDocument copyWith({
    int? rows,
    int? cols,
    List<Item>? items,
    List<Sticker>? stickers,
    List<Floor>? floors,
    String? defaultFloorId,
  }) {
    return GridDocument(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      items: items ?? this.items,
      stickers: stickers ?? this.stickers,
      floors: floors ?? this.floors,
      defaultFloorId: defaultFloorId ?? this.defaultFloorId,
    );
  }

  Map<String, dynamic> toJsonMap() => {
    'rows': rows,
    'cols': cols,
    'items': [for (final item in items) item.toJson()],
    if (stickers.isNotEmpty)
      'stickers': [for (final sticker in stickers) sticker.toJson()],
    if (defaultFloorId != null) 'defaultFloorId': defaultFloorId,
    if (floors.isNotEmpty) 'floors': [for (final floor in floors) floor.toJson()],
  };

  factory GridDocument.fromJsonMap(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawStickers = json['stickers'] as List<dynamic>? ?? [];
    final rawFloors = json['floors'] as List<dynamic>? ?? [];
    return GridDocument(
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      defaultFloorId: json['defaultFloorId'] as String?,
      items: [
        for (final entry in rawItems)
          Item.fromJson(entry as Map<String, dynamic>),
      ],
      stickers: [
        for (final entry in rawStickers)
          Sticker.fromJson(entry as Map<String, dynamic>),
      ],
      floors: [
        for (final entry in rawFloors)
          Floor.fromJson(entry as Map<String, dynamic>),
      ],
    );
  }
}
