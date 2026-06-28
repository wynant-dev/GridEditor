import '../catalog/item.dart';
import '../catalog/catalog.dart';
import '../layout/grid_document.dart';
import '../layout/placed_item.dart';

/// Pure placement rules — bridges catalog definitions with layout state.
class PlacementRules {
  const PlacementRules._();

  /// Returns null when valid, otherwise an error message.
  static String? placementError({
    required Catalog catalog,
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
    required Catalog catalog,
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
    required Catalog catalog,
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

  /// Placement origin so [anchorRow]/[anchorCol] sits at the item center.
  static (int originRow, int originCol) originFromCenterAnchor({
    required GridDocument layout,
    required CatalogItem item,
    required int anchorRow,
    required int anchorCol,
  }) {
    var originRow = anchorRow - item.height ~/ 2;
    var originCol = anchorCol - item.width ~/ 2;
    originRow = originRow.clamp(0, layout.rows - item.height);
    originCol = originCol.clamp(0, layout.cols - item.width);
    return (originRow, originCol);
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
    return cellInProposedFootprint(
      item: item,
      originRow: placement.originRow,
      originCol: placement.originCol,
      row: row,
      col: col,
    );
  }

  /// Whether [row]/[col] lies inside a proposed item footprint.
  static bool cellInProposedFootprint({
    required CatalogItem item,
    required int originRow,
    required int originCol,
    required int row,
    required int col,
  }) {
    return row >= originRow &&
        row < originRow + item.height &&
        col >= originCol &&
        col < originCol + item.width;
  }

  /// Whether a single footprint cell can be placed at the proposed origin.
  static bool isFootprintCellValid({
    required Catalog catalog,
    required GridDocument layout,
    required CatalogItem item,
    required int originRow,
    required int originCol,
    required int row,
    required int col,
    String? ignorePlacementId,
  }) {
    if (!cellInProposedFootprint(
      item: item,
      originRow: originRow,
      originCol: originCol,
      row: row,
      col: col,
    )) {
      return false;
    }

    if (row < 0 ||
        col < 0 ||
        row >= layout.rows ||
        col >= layout.cols) {
      return false;
    }

    final covering = placementCovering(
      catalog: catalog,
      layout: layout,
      row: row,
      col: col,
    );
    if (covering == null) return true;
    if (covering.id == ignorePlacementId) return true;
    return false;
  }
}
