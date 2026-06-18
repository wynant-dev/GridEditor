import 'dart:ui';

import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../geometry/grid_coordinate_mapper.dart';

sealed class GridHit {}

class CellHit extends GridHit {
  CellHit({required this.row, required this.col});

  final int row;
  final int col;
}

class PlacementHit extends GridHit {
  PlacementHit({
    required this.placement,
    required this.row,
    required this.col,
  });

  final PlacedItem placement;
  final int row;
  final int col;
}

/// Classifies pointer positions into cell or placement targets before tool dispatch.
class GridHitTester {
  const GridHitTester({
    required this.mapper,
    required this.document,
    required this.catalog,
  });

  final GridCoordinateMapper mapper;
  final GridDocument document;
  final ItemCatalog catalog;

  (int row, int col) cellAt(Offset worldPosition) {
    return mapper.fromWorldPosition(worldPosition);
  }

  GridHit classifyTap(Offset worldPosition) {
    final placement = mapper.hitTestPlacement(
      worldPosition,
      document,
      catalog,
    );
    final (row, col) = mapper.fromWorldPosition(worldPosition);

    if (placement != null) {
      return PlacementHit(placement: placement, row: row, col: col);
    }

    return CellHit(row: row, col: col);
  }
}
