import 'package:flutter/material.dart';

import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../catalog_color_resolver.dart';
import '../geometry/grid_metrics.dart';

/// Paints grid lines and placements. Does not handle input or editor state.
class GridRenderer extends StatelessWidget {
  const GridRenderer({
    super.key,
    required this.document,
    required this.catalog,
    required this.metrics,
    this.hiddenPlacementId,
  });

  final GridDocument document;
  final ItemCatalog catalog;
  final GridMetrics metrics;
  final String? hiddenPlacementId;

  @override
  Widget build(BuildContext context) {
    final lineColor = Colors.grey.shade400;

    return Stack(
      children: [
        CustomPaint(
          size: metrics.size,
          painter: _GridLinePainter(metrics: metrics, color: lineColor),
        ),
        for (final placement in document.placements)
          if (placement.id != hiddenPlacementId)
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

class _PlacementLayer extends StatelessWidget {
  const _PlacementLayer({
    required this.placement,
    required this.catalog,
    required this.metrics,
  });

  final PlacedItem placement;
  final ItemCatalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final item = catalog.itemById(placement.catalogItemId);
    if (item == null) return const SizedBox.shrink();

    final color = CatalogColorResolver.fromItem(item);
    final topLeft = metrics.cellTopLeft(
      placement.originRow,
      placement.originCol,
    );

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: item.width * metrics.cellWidth,
      height: item.height * metrics.cellHeight,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black26, width: 3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ),
      ),
    );
  }
}
