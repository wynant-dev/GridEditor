import 'dart:ui';

import '../catalog/catalog.dart';
import '../layout/grid_document.dart';
import '../layout/item.dart';
import '../layout/sticker.dart';
import '../rules/sticker_rules.dart';
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

  Item? hitTestItem(
    Offset worldPosition,
    GridDocument document,
    Catalog catalog,
  ) {
    for (final layoutItem in document.items.reversed) {
      final catalogItem = catalog.itemById(layoutItem.catalogItemId);
      if (catalogItem == null) continue;

      final topLeft = metrics.cellTopLeft(
        layoutItem.originRow,
        layoutItem.originCol,
      );
      final rect = Rect.fromLTWH(
        topLeft.dx,
        topLeft.dy,
        catalogItem.width * metrics.cellWidth,
        catalogItem.height * metrics.cellHeight,
      );

      if (rect.contains(worldPosition)) {
        return layoutItem;
      }
    }

    return null;
  }

  Sticker? hitTestSticker(
    Offset worldPosition,
    GridDocument document,
    Catalog catalog, {
    double size = StickerRules.kDefaultStickerSize,
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
