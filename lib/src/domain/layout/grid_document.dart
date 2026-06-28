import 'floor_tile.dart';
import 'placed_item.dart';
import 'placed_sticker.dart';

/// Immutable grid layout state (pure logic, no Flutter).
class GridDocument {
  const GridDocument({
    required this.rows,
    required this.cols,
    this.placements = const [],
    this.stickers = const [],
    this.floorTiles = const [],
    this.defaultFloorId,
  }) : assert(rows > 0),
       assert(cols > 0);

  final int rows;
  final int cols;
  final List<PlacedItem> placements;
  final List<PlacedSticker> stickers;

  /// Per-cell overrides; cells not listed use [defaultFloorId] when set.
  final List<FloorTile> floorTiles;
  final String? defaultFloorId;

  PlacedItem? placementById(String id) {
    for (final placement in placements) {
      if (placement.id == id) return placement;
    }
    return null;
  }

  PlacedSticker? stickerById(String id) {
    for (final sticker in stickers) {
      if (sticker.id == id) return sticker;
    }
    return null;
  }

  String? floorIdAt(int row, int col) {
    for (final tile in floorTiles) {
      if (tile.row == row && tile.col == col) {
        return tile.catalogFloorId;
      }
    }
    return defaultFloorId;
  }

  GridDocument copyWith({
    int? rows,
    int? cols,
    List<PlacedItem>? placements,
    List<PlacedSticker>? stickers,
    List<FloorTile>? floorTiles,
    String? defaultFloorId,
  }) {
    return GridDocument(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      placements: placements ?? this.placements,
      stickers: stickers ?? this.stickers,
      floorTiles: floorTiles ?? this.floorTiles,
      defaultFloorId: defaultFloorId ?? this.defaultFloorId,
    );
  }

  Map<String, dynamic> toJsonMap() => {
    'rows': rows,
    'cols': cols,
    'placements': [for (final p in placements) p.toJson()],
    if (stickers.isNotEmpty)
      'stickers': [for (final s in stickers) s.toJson()],
    if (defaultFloorId != null) 'defaultFloorId': defaultFloorId,
    if (floorTiles.isNotEmpty)
      'floorTiles': [for (final tile in floorTiles) tile.toJson()],
  };

  factory GridDocument.fromJsonMap(Map<String, dynamic> json) {
    final rawPlacements = json['placements'] as List<dynamic>? ?? [];
    final rawStickers = json['stickers'] as List<dynamic>? ?? [];
    final rawFloorTiles = json['floorTiles'] as List<dynamic>? ?? [];
    return GridDocument(
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      defaultFloorId: json['defaultFloorId'] as String?,
      placements: [
        for (final entry in rawPlacements)
          PlacedItem.fromJson(entry as Map<String, dynamic>),
      ],
      stickers: [
        for (final entry in rawStickers)
          PlacedSticker.fromJson(entry as Map<String, dynamic>),
      ],
      floorTiles: [
        for (final entry in rawFloorTiles)
          FloorTile.fromJson(entry as Map<String, dynamic>),
      ],
    );
  }
}
