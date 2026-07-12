import '../catalog/catalog.dart';
import '../layout/grid_document.dart';

/// Rules for [CatalogFloor] → [Floor].
class FloorRules {
  const FloorRules._();

  /// Returns null when valid, otherwise an error message.
  static String? floorError({
    required Catalog catalog,
    required GridDocument layout,
    required int row,
    required int col,
    required String catalogFloorId,
  }) {
    if (catalog.floorById(catalogFloorId) == null) {
      return 'Unknown floor: $catalogFloorId';
    }

    if (!isCellInBounds(layout, row, col)) {
      return 'Floor cell is out of bounds';
    }

    return null;
  }

  static bool isCellInBounds(GridDocument layout, int row, int col) {
    return row >= 0 &&
        row < layout.rows &&
        col >= 0 &&
        col < layout.cols;
  }
}
