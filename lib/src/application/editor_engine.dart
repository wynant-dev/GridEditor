import 'dart:convert';

import '../domain/catalog/catalog.dart';
import '../domain/layout/floor_tile.dart';
import '../domain/layout/grid_document.dart';
import '../domain/layout/placed_item.dart';
import '../domain/placement/placement_rules.dart';

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
}
