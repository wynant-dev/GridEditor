import 'dart:ui';

import '../catalog/catalog.dart';
import '../layout/grid_document.dart';
import '../layout/placed_item.dart';
import '../layout/placed_sticker.dart';
import '../sticker/sticker_bounds.dart';
import 'grid_metrics.dart';

/// Converts pointer positions on the canvas into grid cell coordinates.
///
/// Centralizes layout math so future zoom, pan, and transform support can be
/// added here without changing hover or input handling call sites.
class GridCoordinateMapper {
  const GridCoordinateMapper(this.metrics);

  final GridMetrics metrics;

  (int row, int col) fromLocalPosition(Offset position) {
    return fromWorldPosition(metrics.screenToWorld(position));
  }

  (int row, int col) fromWorldPosition(Offset position) {
    final local = position - metrics.origin;
    final row = (local.dy / metrics.cellHeight).floor().clamp(
      0,
      metrics.rows - 1,
    );
    final col = (local.dx / metrics.cellWidth).floor().clamp(
      0,
      metrics.cols - 1,
    );

    return (row, col);
  }

  PlacedItem? hitTestPlacement(
    Offset worldPosition,
    GridDocument document,
    Catalog catalog,
  ) {
    for (final placement in document.placements.reversed) {
      final item = catalog.itemById(placement.catalogItemId);
      if (item == null) continue;

      final topLeft = metrics.cellTopLeft(
        placement.originRow,
        placement.originCol,
      );
      final rect = Rect.fromLTWH(
        topLeft.dx,
        topLeft.dy,
        item.width * metrics.cellWidth,
        item.height * metrics.cellHeight,
      );

      if (rect.contains(worldPosition)) {
        return placement;
      }
    }

    return null;
  }

  PlacedSticker? hitTestSticker(
    Offset worldPosition,
    GridDocument document,
    Catalog catalog, {
    double size = StickerBounds.kDefaultStickerSize,
  }) {
    final half = size / 2;
    for (final sticker in document.stickers.reversed) {
      if (catalog.stickerById(sticker.catalogStickerId) == null) continue;

      final rect = Rect.fromLTWH(
        sticker.x - half,
        sticker.y - half,
        size,
        size,
      );

      if (rect.contains(worldPosition)) {
        return sticker;
      }
    }

    return null;
  }
}
