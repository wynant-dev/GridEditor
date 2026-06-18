import '../domain/catalog/catalog_item.dart';
import '../domain/catalog/item_catalog.dart';
import '../domain/layout/grid_document.dart';
import '../domain/layout/placed_item.dart';

/// Pure placement rules — bridges catalog definitions with layout state.
class PlacementRules {
  const PlacementRules._();

  /// Returns null when valid, otherwise an error message.
  static String? placementError({
    required ItemCatalog catalog,
    required GridDocument layout,
    required String catalogItemId,
    required int originRow,
    required int originCol,
    String? ignorePlacementId,
  }) {
    final item = catalog.itemById(catalogItemId);
    if (item == null) return 'Unknown item: $catalogItemId';

    if (!fitsOnGrid(layout, item, originRow, originCol)) {
      return 'Item does not fit on the grid';
    }

    for (final placement in layout.placements) {
      if (placement.id == ignorePlacementId) continue;
      final other = catalog.itemById(placement.catalogItemId);
      if (other == null) continue;
      if (overlaps(item, originRow, originCol, other, placement)) {
        return 'Item overlaps another placement';
      }
    }

    return null;
  }

  static bool occupiesCell({
    required ItemCatalog catalog,
    required GridDocument layout,
    required int row,
    required int col,
  }) {
    return placementCovering(
          catalog: catalog,
          layout: layout,
          row: row,
          col: col,
        ) !=
        null;
  }

  static PlacedItem? placementCovering({
    required ItemCatalog catalog,
    required GridDocument layout,
    required int row,
    required int col,
  }) {
    for (final placement in layout.placements) {
      final item = catalog.itemById(placement.catalogItemId);
      if (item == null) continue;
      if (cellInFootprint(item, placement, row, col)) return placement;
    }
    return null;
  }

  static bool fitsOnGrid(
    GridDocument layout,
    CatalogItem item,
    int originRow,
    int originCol,
  ) {
    return originRow >= 0 &&
        originCol >= 0 &&
        originRow + item.height <= layout.rows &&
        originCol + item.width <= layout.cols;
  }

  static bool overlaps(
    CatalogItem item,
    int originRow,
    int originCol,
    CatalogItem otherItem,
    PlacedItem otherPlacement,
  ) {
    final aLeft = originCol;
    final aRight = originCol + item.width;
    final aTop = originRow;
    final aBottom = originRow + item.height;

    final bLeft = otherPlacement.originCol;
    final bRight = otherPlacement.originCol + otherItem.width;
    final bTop = otherPlacement.originRow;
    final bBottom = otherPlacement.originRow + otherItem.height;

    return aLeft < bRight &&
        aRight > bLeft &&
        aTop < bBottom &&
        aBottom > bTop;
  }

  static bool cellInFootprint(
    CatalogItem item,
    PlacedItem placement,
    int row,
    int col,
  ) {
    return row >= placement.originRow &&
        row < placement.originRow + item.height &&
        col >= placement.originCol &&
        col < placement.originCol + item.width;
  }
}
