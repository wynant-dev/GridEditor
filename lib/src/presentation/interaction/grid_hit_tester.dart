import 'dart:ui';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/geometry/grid_coordinate_mapper.dart';
import 'grid_hit.dart';

/// Classifies pointer positions into cell or placement targets before tool dispatch.
class GridHitTester {
  const GridHitTester({
    required this.mapper,
    required this.document,
    required this.catalog,
  });

  final GridCoordinateMapper mapper;
  final GridDocument document;
  final Catalog catalog;

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
