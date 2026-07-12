import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/floor.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/item.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../theme/catalog_color_resolver.dart';
import 'floor_cell.dart';
import 'item_box.dart';
import 'sticker_layers.dart';

/// Default + per-cell floor tiles (bottom paint layer).
class FloorLayers extends StatelessWidget {
  const FloorLayers({
    super.key,
    required this.document,
    required this.catalog,
    required this.metrics,
  });

  final GridDocument document;
  final Catalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _DefaultFloorLayer(
          document: document,
          catalog: catalog,
          metrics: metrics,
        ),
        for (final floor in document.floors)
          _FloorLayer(
            floor: floor,
            catalog: catalog,
            metrics: metrics,
          ),
      ],
    );
  }
}

/// Grid line overlay.
class GridLinesLayer extends StatelessWidget {
  static const double gridLineOpacity = 0.35;

  const GridLinesLayer({
    super.key,
    required this.metrics,
  });

  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final lineColor = Colors.black.withValues(alpha: gridLineOpacity);

    return Positioned(
      left: metrics.origin.dx,
      top: metrics.origin.dy,
      width: metrics.gridSize.width,
      height: metrics.gridSize.height,
      child: CustomPaint(
        size: metrics.gridSize,
        painter: _GridLinePainter(metrics: metrics, color: lineColor),
      ),
    );
  }
}

/// Catalog items in the scene (committed or semi-transparent ghosts).
class ItemLayers extends StatelessWidget {
  const ItemLayers({
    super.key,
    required this.document,
    required this.catalog,
    required this.metrics,
    this.hiddenItemId,
    this.ghostOpacity,
  });

  final GridDocument document;
  final Catalog catalog;
  final GridMetrics metrics;

  /// Omitted while dragging so the overlay can draw the ghost.
  final String? hiddenItemId;

  /// When set, all items render at this opacity (floor-paint mode).
  final double? ghostOpacity;

  @override
  Widget build(BuildContext context) {
    final inGhostMode = ghostOpacity != null;
    final opacity = ghostOpacity ?? 1.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final item in document.items)
          if (inGhostMode || item.id != hiddenItemId)
            _ItemLayer(
              item: item,
              catalog: catalog,
              metrics: metrics,
              opacity: opacity,
            ),
      ],
    );
  }
}

/// Read-only stack: floors, grid lines, items (no editor overlays).
class GridRenderer extends StatelessWidget {
  const GridRenderer({
    super.key,
    required this.document,
    required this.catalog,
    required this.metrics,
    this.hiddenItemId,
    this.hiddenStickerId,
  });

  final GridDocument document;
  final Catalog catalog;
  final GridMetrics metrics;
  final String? hiddenItemId;
  final String? hiddenStickerId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloorLayers(
          document: document,
          catalog: catalog,
          metrics: metrics,
        ),
        GridLinesLayer(metrics: metrics),
        ItemLayers(
          document: document,
          catalog: catalog,
          metrics: metrics,
          hiddenItemId: hiddenItemId,
        ),
        StickerLayers(
          document: document,
          catalog: catalog,
          hiddenStickerId: hiddenStickerId,
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
        oldDelegate.metrics.gridSize != metrics.gridSize ||
        oldDelegate.metrics.origin != metrics.origin ||
        oldDelegate.metrics.cellSize != metrics.cellSize ||
        oldDelegate.metrics.transform.offset != metrics.transform.offset ||
        oldDelegate.metrics.transform.zoom != metrics.transform.zoom ||
        oldDelegate.color != color;
  }
}

class _DefaultFloorLayer extends StatelessWidget {
  const _DefaultFloorLayer({
    required this.document,
    required this.catalog,
    required this.metrics,
  });

  final GridDocument document;
  final Catalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final defaultFloorId = document.defaultFloorId;
    if (defaultFloorId == null) return const SizedBox.shrink();

    final floor = catalog.floorById(defaultFloorId);
    if (floor == null) return const SizedBox.shrink();

    return Positioned(
      left: metrics.origin.dx,
      top: metrics.origin.dy,
      width: metrics.gridSize.width,
      height: metrics.gridSize.height,
      child: ColoredBox(color: CatalogColorResolver.fromFloor(floor)),
    );
  }
}

class _FloorLayer extends StatelessWidget {
  const _FloorLayer({
    required this.floor,
    required this.catalog,
    required this.metrics,
  });

  final Floor floor;
  final Catalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final catalogFloor = catalog.floorById(floor.catalogFloorId);
    if (catalogFloor == null) return const SizedBox.shrink();

    return FloorCell(
      color: CatalogColorResolver.fromFloor(catalogFloor),
      metrics: metrics,
      row: floor.row,
      col: floor.col,
    );
  }
}

class _ItemLayer extends StatelessWidget {
  const _ItemLayer({
    required this.item,
    required this.catalog,
    required this.metrics,
    required this.opacity,
  });

  final Item item;
  final Catalog catalog;
  final GridMetrics metrics;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final catalogItem = catalog.itemById(item.catalogItemId);
    if (catalogItem == null) return const SizedBox.shrink();

    return ItemBox(
      itemName: catalogItem.name,
      color: CatalogColorResolver.fromItem(catalogItem),
      iconName: catalogItem.iconName,
      metrics: metrics,
      row: item.originRow,
      col: item.originCol,
      width: catalogItem.width,
      height: catalogItem.height,
      opacity: opacity,
    );
  }
}
