import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/catalog/catalog_item.dart';
import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../../services/editor_controller.dart';
import 'grid_coordinate_mapper.dart';
import 'grid_metrics.dart';

bool _supportsHoverPreview() {
  if (kIsWeb) return true;
  switch (defaultTargetPlatform) {
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return true;
    default:
      return false;
  }
}

class GridCanvas extends StatelessWidget {
  const GridCanvas({
    super.key,
    required this.document,
    required this.catalog,
    this.controller,
    this.onCellTap,
    this.onPlacementTap,
  });

  final GridDocument document;
  final ItemCatalog catalog;
  final EditorController? controller;
  final void Function(int row, int col)? onCellTap;
  final void Function(PlacedItem placement)? onPlacementTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = GridMetrics(
          rows: document.rows,
          cols: document.cols,
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
        final mapper = GridCoordinateMapper(metrics);
        final lineColor = Colors.grey.shade400;

        Widget grid = Stack(
          children: [
            CustomPaint(
              size: metrics.size,
              painter: _GridLinePainter(
                metrics: metrics,
                color: lineColor,
              ),
            ),
            Column(
              children: List.generate(document.rows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(document.cols, (col) {
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onCellTap?.call(row, col),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
            for (final placement in document.placements)
              _PlacementLayer(
                placement: placement,
                catalog: catalog,
                metrics: metrics,
                onTap: () => onPlacementTap?.call(placement),
              ),
            if (controller != null) ...[
              _GhostPreviewLayer(
                controller: controller!,
                catalog: catalog,
                metrics: metrics,
              ),
            ],
          ],
        );

        final editorController = controller;
        if (editorController != null && _supportsHoverPreview()) {
          grid = MouseRegion(
            onHover: (event) {
              final (row, col) = mapper.fromLocalPosition(event.localPosition);
              editorController.setHoverCell(row, col);
            },
            onExit: (_) => editorController.setHoverCell(null, null),
            child: grid,
          );
        }

        return grid;
      },
    );
  }
}

class _GridLinePainter extends CustomPainter {
  const _GridLinePainter({
    required this.metrics,
    required this.color,
  });

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
        oldDelegate.color != color;
  }
}

class _GhostPreviewLayer extends StatelessWidget {
  const _GhostPreviewLayer({
    required this.controller,
    required this.catalog,
    required this.metrics,
  });

  final EditorController controller;
  final ItemCatalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final selectedId = controller.selectedItemId;
    final hoverRow = controller.hoverRow;
    final hoverCol = controller.hoverCol;
    if (selectedId == null || hoverRow == null || hoverCol == null) {
      return const SizedBox.shrink();
    }

    final item = catalog.itemById(selectedId);
    if (item == null) return const SizedBox.shrink();

    final color = _catalogItemColor(item);
    final topLeft = metrics.cellTopLeft(hoverRow, hoverCol);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: item.width * metrics.cellWidth,
      height: item.height * metrics.cellHeight,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black26, width: 1.5),
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
      ),
    );
  }
}

class _PlacementLayer extends StatelessWidget {
  const _PlacementLayer({
    required this.placement,
    required this.catalog,
    required this.metrics,
    this.onTap,
  });

  final PlacedItem placement;
  final ItemCatalog catalog;
  final GridMetrics metrics;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final item = catalog.itemById(placement.catalogItemId);
    if (item == null) return const SizedBox.shrink();

    final color = _catalogItemColor(item);
    final topLeft = metrics.cellTopLeft(placement.originRow, placement.originCol);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: item.width * metrics.cellWidth,
      height: item.height * metrics.cellHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black54),
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

Color _catalogItemColor(CatalogItem item) {
  return _parseColor(item.color) ?? Colors.blueGrey.shade200;
}

Color? _parseColor(String? value) {
  if (value == null || value.isEmpty) return null;
  final hex = value.startsWith('#') ? value.substring(1) : value;
  if (hex.length == 6) {
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed != null) return Color(0xFF000000 | parsed);
  }
  return null;
}
