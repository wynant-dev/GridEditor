import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/floor_tile.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../theme/catalog_color_resolver.dart';
import 'floor_cell.dart';
import 'placement_box.dart';

/// Paints grid lines and placements. Does not handle input or editor state.
class GridRenderer extends StatelessWidget {
  const GridRenderer({
    super.key,
    required this.document,
    required this.catalog,
    required this.metrics,
    this.hiddenPlacementId,
    this.hidePlacements = false,
  });

  final GridDocument document;
  final Catalog catalog;
  final GridMetrics metrics;
  final String? hiddenPlacementId;

  /// When true, committed placements are omitted so an overlay can draw them.
  final bool hidePlacements;

  @override
  Widget build(BuildContext context) {
    final lineColor = Colors.grey.shade400;

    return Stack(
      children: [
        for (final tile in document.floorTiles)
          _FloorLayer(
            tile: tile,
            catalog: catalog,
            metrics: metrics,
          ),
        CustomPaint(
          size: metrics.size,
          painter: _GridLinePainter(metrics: metrics, color: lineColor),
        ),
        for (final placement in document.placements)
          if (!hidePlacements && placement.id != hiddenPlacementId)
            _PlacementLayer(
              placement: placement,
              catalog: catalog,
              metrics: metrics,
            ),
      ],
    );
  }
}

class _GridLinePainter extends CustomPainter {
  const _GridLinePainter({required this.metrics, required this.color});

  final GridMetrics metrics;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (var col = 0; col <= metrics.cols; col++) {
      final x = col * metrics.cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var row = 0; row <= metrics.rows; row++) {
      final y = row * metrics.cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinePainter oldDelegate) {
    return oldDelegate.metrics.rows != metrics.rows ||
        oldDelegate.metrics.cols != metrics.cols ||
        oldDelegate.metrics.size != metrics.size ||
        oldDelegate.metrics.transform.offset != metrics.transform.offset ||
        oldDelegate.metrics.transform.zoom != metrics.transform.zoom ||
        oldDelegate.color != color;
  }
}

class _FloorLayer extends StatelessWidget {
  const _FloorLayer({
    required this.tile,
    required this.catalog,
    required this.metrics,
  });

  final FloorTile tile;
  final Catalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final floor = catalog.floorById(tile.catalogFloorId);
    if (floor == null) return const SizedBox.shrink();

    return FloorCell(
      color: CatalogColorResolver.fromFloor(floor),
      metrics: metrics,
      row: tile.row,
      col: tile.col,
    );
  }
}

class _PlacementLayer extends StatelessWidget {
  const _PlacementLayer({
    required this.placement,
    required this.catalog,
    required this.metrics,
  });

  final PlacedItem placement;
  final Catalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final item = catalog.itemById(placement.catalogItemId);
    if (item == null) return const SizedBox.shrink();

    return PlacementBox(
      itemName: item.name,
      color: CatalogColorResolver.fromItem(item),
      metrics: metrics,
      row: placement.originRow,
      col: placement.originCol,
      width: item.width,
      height: item.height,
    );
  }
}
