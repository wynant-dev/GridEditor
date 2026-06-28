import 'dart:convert';
import 'dart:ui';

import '../domain/catalog/catalog.dart';
import '../domain/layout/floor_tile.dart';
import '../domain/layout/grid_document.dart';
import '../domain/layout/placed_item.dart';
import '../domain/layout/placed_sticker.dart';
import '../domain/placement/placement_rules.dart';
import '../domain/sticker/sticker_bounds.dart';

/// Bridge between catalog (what exists) and layout (what is placed).
class EditorEngine {
  const EditorEngine({required this.catalog, required this.layout});

  final Catalog catalog;
  final GridDocument layout;

  EditorEngine copyWith({Catalog? catalog, GridDocument? layout}) {
    return EditorEngine(
      catalog: catalog ?? this.catalog,
      layout: layout ?? this.layout,
    );
  }

  EditorEngine resize({required int rows, required int cols}) {
    return copyWith(
      layout: layout.copyWith(rows: rows, cols: cols),
    );
  }

  String? placementError({
    required String catalogItemId,
    required int originRow,
    required int originCol,
    String? ignorePlacementId,
  }) {
    return PlacementRules.placementError(
      catalog: catalog,
      layout: layout,
      catalogItemId: catalogItemId,
      originRow: originRow,
      originCol: originCol,
      ignorePlacementId: ignorePlacementId,
    );
  }

  EditorEngine placeItem({
    required String catalogItemId,
    required int originRow,
    required int originCol,
    String? placementId,
  }) {
    final error = placementError(
      catalogItemId: catalogItemId,
      originRow: originRow,
      originCol: originCol,
    );
    if (error != null) {
      throw StateError(error);
    }

    final placement = PlacedItem(
      id: placementId ?? _nextPlacementId(),
      catalogItemId: catalogItemId,
      originRow: originRow,
      originCol: originCol,
    );

    return copyWith(
      layout: layout.copyWith(placements: [...layout.placements, placement]),
    );
  }

  EditorEngine removePlacement(String placementId) {
    return copyWith(
      layout: layout.copyWith(
        placements: [
          for (final placement in layout.placements)
            if (placement.id != placementId) placement,
        ],
      ),
    );
  }

  EditorEngine movePlacement({
    required String placementId,
    required int newRow,
    required int newCol,
  }) {
    final existing = placementById(placementId);
    if (existing == null) {
      throw StateError('Placement not found');
    }

    final error = placementError(
      catalogItemId: existing.catalogItemId,
      originRow: newRow,
      originCol: newCol,
      ignorePlacementId: placementId,
    );
    if (error != null) {
      throw StateError(error);
    }

    final without = removePlacement(placementId);
    return without.placeItem(
      catalogItemId: existing.catalogItemId,
      originRow: newRow,
      originCol: newCol,
      placementId: placementId,
    );
  }

  bool occupiesCell({required int row, required int col}) {
    return PlacementRules.occupiesCell(
      catalog: catalog,
      layout: layout,
      row: row,
      col: col,
    );
  }

  PlacedItem? placementCovering({required int row, required int col}) {
    return PlacementRules.placementCovering(
      catalog: catalog,
      layout: layout,
      row: row,
      col: col,
    );
  }

  PlacedItem? placementById(String id) => layout.placementById(id);

  PlacedSticker? stickerById(String id) => layout.stickerById(id);

  String? stickerError({
    required String catalogStickerId,
    required double x,
    required double y,
    required double cellSize,
    required Offset origin,
  }) {
    if (catalog.stickerById(catalogStickerId) == null) {
      return 'Unknown sticker: $catalogStickerId';
    }
    if (!StickerBounds.isCenterInGrid(
      rows: layout.rows,
      cols: layout.cols,
      cellSize: cellSize,
      origin: origin,
      centerX: x,
      centerY: y,
    )) {
      return 'Sticker is out of bounds';
    }
    return null;
  }

  EditorEngine placeSticker({
    required String catalogStickerId,
    required double x,
    required double y,
    required double cellSize,
    required Offset origin,
    String? stickerId,
  }) {
    final error = stickerError(
      catalogStickerId: catalogStickerId,
      x: x,
      y: y,
      cellSize: cellSize,
      origin: origin,
    );
    if (error != null) {
      throw StateError(error);
    }

    final sticker = PlacedSticker(
      id: stickerId ?? _nextStickerId(),
      catalogStickerId: catalogStickerId,
      x: x,
      y: y,
    );

    return copyWith(
      layout: layout.copyWith(stickers: [...layout.stickers, sticker]),
    );
  }

  EditorEngine removeSticker(String stickerId) {
    return copyWith(
      layout: layout.copyWith(
        stickers: [
          for (final sticker in layout.stickers)
            if (sticker.id != stickerId) sticker,
        ],
      ),
    );
  }

  EditorEngine moveSticker({
    required String stickerId,
    required double x,
    required double y,
    required double cellSize,
    required Offset origin,
  }) {
    final existing = stickerById(stickerId);
    if (existing == null) {
      throw StateError('Sticker not found');
    }

    final error = stickerError(
      catalogStickerId: existing.catalogStickerId,
      x: x,
      y: y,
      cellSize: cellSize,
      origin: origin,
    );
    if (error != null) {
      throw StateError(error);
    }

    return copyWith(
      layout: layout.copyWith(
        stickers: [
          for (final sticker in layout.stickers)
            if (sticker.id == stickerId)
              sticker.copyWith(x: x, y: y)
            else
              sticker,
        ],
      ),
    );
  }

  String? floorIdAt(int row, int col) => layout.floorIdAt(row, col);

  EditorEngine applyFloor({
    required int row,
    required int col,
    required String catalogFloorId,
  }) {
    if (row < 0 || row >= layout.rows || col < 0 || col >= layout.cols) {
      throw StateError('Floor cell is out of bounds');
    }

    final floor = catalog.floorById(catalogFloorId);
    if (floor == null) {
      throw StateError('Unknown floor: $catalogFloorId');
    }

    final withoutCell = [
      for (final tile in layout.floorTiles)
        if (tile.row != row || tile.col != col) tile,
    ];
    final updatedTiles = catalogFloorId == layout.defaultFloorId
        ? withoutCell
        : [
            ...withoutCell,
            FloorTile(row: row, col: col, catalogFloorId: catalogFloorId),
          ];

    return copyWith(
      layout: layout.copyWith(floorTiles: updatedTiles),
    );
  }

  String layoutToJson() => jsonEncode(layout.toJsonMap());

  factory EditorEngine.fromLayoutJson({
    required Catalog catalog,
    required String source,
  }) {
    return EditorEngine(
      catalog: catalog,
      layout: GridDocument.fromJsonMap(
        jsonDecode(source) as Map<String, dynamic>,
      ),
    );
  }

  String _nextPlacementId() {
    var max = 0;
    for (final placement in layout.placements) {
      final match = RegExp(r'^p(\d+)$').firstMatch(placement.id);
      if (match == null) continue;
      final value = int.tryParse(match.group(1)!);
      if (value != null && value > max) {
        max = value;
      }
    }
    return 'p${max + 1}';
  }

  String _nextStickerId() {
    var max = 0;
    for (final sticker in layout.stickers) {
      final match = RegExp(r'^s(\d+)$').firstMatch(sticker.id);
      if (match == null) continue;
      final value = int.tryParse(match.group(1)!);
      if (value != null && value > max) {
        max = value;
      }
    }
    return 's${max + 1}';
  }
}
