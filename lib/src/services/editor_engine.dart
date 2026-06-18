import 'dart:convert';

import '../domain/catalog/item_catalog.dart';
import '../domain/layout/grid_document.dart';
import '../domain/layout/placed_item.dart';
import 'placement_rules.dart';

/// Bridge between catalog (what exists) and layout (what is placed).
class EditorEngine {
  const EditorEngine({required this.catalog, required this.layout});

  final ItemCatalog catalog;
  final GridDocument layout;

  EditorEngine copyWith({ItemCatalog? catalog, GridDocument? layout}) {
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

  String layoutToJson() => jsonEncode(layout.toJsonMap());

  factory EditorEngine.fromLayoutJson({
    required ItemCatalog catalog,
    required String source,
  }) {
    return EditorEngine(
      catalog: catalog,
      layout: GridDocument.fromJsonMap(
        jsonDecode(source) as Map<String, dynamic>,
      ),
    );
  }

  String _nextPlacementId() => 'p${layout.placements.length + 1}';
}
