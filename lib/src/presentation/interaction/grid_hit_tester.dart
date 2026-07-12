import 'dart:ui';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/geometry/grid_coordinate_mapper.dart';
import 'grid_hit.dart';

/// Classifies pointer positions into sticker, cell, or item targets before tool dispatch.
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

  Offset worldAt(Offset viewportPosition) {
    return mapper.metrics.screenToWorld(viewportPosition);
  }

  GridHit classifyTap(Offset viewportPosition) {
    final world = worldAt(viewportPosition);
    final (row, col) = cellAt(viewportPosition);

    final sticker = mapper.hitTestSticker(world, document, catalog);
    if (sticker != null) {
      return StickerHit(sticker: sticker, row: row, col: col);
    }

    final item = mapper.hitTestItem(
      world,
      document,
      catalog,
    );

    if (item != null) {
      return ItemHit(item: item, row: row, col: col);
    }

    return CellHit(row: row, col: col);
  }
}
