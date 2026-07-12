import '../catalog/item.dart';
import '../catalog/catalog.dart';
import '../layout/grid_document.dart';
import '../layout/item.dart';

/// Rules for [CatalogItem] → [Item].
class ItemRules {
  const ItemRules._();

  /// Returns null when valid, otherwise an error message.
  static String? itemError({
    required Catalog catalog,
    required GridDocument layout,
    required String catalogItemId,
    required int originRow,
    required int originCol,
    String? ignoreItemId,
  }) {
    final catalogItem = catalog.itemById(catalogItemId);
    if (catalogItem == null) return 'Unknown catalog item: $catalogItemId';

    if (!fitsOnGrid(layout, catalogItem, originRow, originCol)) {
      return 'Item does not fit on the grid';
    }

    for (final item in layout.items) {
      if (item.id == ignoreItemId) continue;
      final other = catalog.itemById(item.catalogItemId);
      if (other == null) continue;
      if (overlaps(catalogItem, originRow, originCol, other, item)) {
        return 'Item overlaps another item';
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
    return itemCovering(
          catalog: catalog,
          layout: layout,
          row: row,
          col: col,
        ) !=
        null;
  }

  static Item? itemCovering({
    required Catalog catalog,
    required GridDocument layout,
    required int row,
    required int col,
  }) {
    for (final item in layout.items) {
      final catalogItem = catalog.itemById(item.catalogItemId);
      if (catalogItem == null) continue;
      if (cellInFootprint(catalogItem, item, row, col)) return item;
    }
    return null;
  }

  static bool fitsOnGrid(
    GridDocument layout,
    CatalogItem catalogItem,
    int originRow,
    int originCol,
  ) {
    return originRow >= 0 &&
        originCol >= 0 &&
        originRow + catalogItem.height <= layout.rows &&
        originCol + catalogItem.width <= layout.cols;
  }

  /// Item origin so [anchorRow]/[anchorCol] sits at the footprint center.
  static (int originRow, int originCol) originFromCenterAnchor({
    required GridDocument layout,
    required CatalogItem catalogItem,
    required int anchorRow,
    required int anchorCol,
  }) {
    var originRow = anchorRow - catalogItem.height ~/ 2;
    var originCol = anchorCol - catalogItem.width ~/ 2;
    originRow = originRow.clamp(0, layout.rows - catalogItem.height);
    originCol = originCol.clamp(0, layout.cols - catalogItem.width);
    return (originRow, originCol);
  }

  static bool overlaps(
    CatalogItem catalogItem,
    int originRow,
    int originCol,
    CatalogItem otherCatalogItem,
    Item otherItem,
  ) {
    final aLeft = originCol;
    final aRight = originCol + catalogItem.width;
    final aTop = originRow;
    final aBottom = originRow + catalogItem.height;

    final bLeft = otherItem.originCol;
    final bRight = otherItem.originCol + otherCatalogItem.width;
    final bTop = otherItem.originRow;
    final bBottom = otherItem.originRow + otherCatalogItem.height;

    return aLeft < bRight &&
        aRight > bLeft &&
        aTop < bBottom &&
        aBottom > bTop;
  }

  static bool cellInFootprint(
    CatalogItem catalogItem,
    Item item,
    int row,
    int col,
  ) {
    return cellInProposedFootprint(
      catalogItem: catalogItem,
      originRow: item.originRow,
      originCol: item.originCol,
      row: row,
      col: col,
    );
  }

  /// Whether [row]/[col] lies inside a proposed item footprint.
  static bool cellInProposedFootprint({
    required CatalogItem catalogItem,
    required int originRow,
    required int originCol,
    required int row,
    required int col,
  }) {
    return row >= originRow &&
        row < originRow + catalogItem.height &&
        col >= originCol &&
        col < originCol + catalogItem.width;
  }

  /// Whether a single footprint cell can be placed at the proposed origin.
  static bool isFootprintCellValid({
    required Catalog catalog,
    required GridDocument layout,
    required CatalogItem catalogItem,
    required int originRow,
    required int originCol,
    required int row,
    required int col,
    String? ignoreItemId,
  }) {
    if (!cellInProposedFootprint(
      catalogItem: catalogItem,
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

    final covering = itemCovering(
      catalog: catalog,
      layout: layout,
      row: row,
      col: col,
    );
    if (covering == null) return true;
    if (covering.id == ignoreItemId) return true;
    return false;
  }
}
