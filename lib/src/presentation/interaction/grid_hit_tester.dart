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

  (int row, int col) cellAt(Offset viewportPosition) {
    return mapper.fromLocalPosition(viewportPosition);
  }

  GridHit classifyTap(Offset viewportPosition) {
    final world = mapper.metrics.screenToWorld(viewportPosition);
    final placement = mapper.hitTestPlacement(
      world,
      document,
      catalog,
    );
    final (row, col) = mapper.fromLocalPosition(viewportPosition);

    if (placement != null) {
      return PlacementHit(placement: placement, row: row, col: col);
    }

    return CellHit(row: row, col: col);
  }
}
