import 'package:flutter/material.dart';

import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';

class GridCanvas extends StatelessWidget {
  const GridCanvas({
    super.key,
    required this.document,
    required this.catalog,
    this.onCellTap,
  });

  final GridDocument document;
  final ItemCatalog catalog;
  final void Function(int row, int col)? onCellTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / document.cols;
        final cellHeight = constraints.maxHeight / document.rows;
        final lineColor = Colors.grey.shade400;

        return Stack(
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _GridLinePainter(
                rows: document.rows,
                cols: document.cols,
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
                cellWidth: cellWidth,
                cellHeight: cellHeight,
              ),
          ],
        );
      },
    );
  }
}

class _GridLinePainter extends CustomPainter {
  const _GridLinePainter({
    required this.rows,
    required this.cols,
    required this.color,
  });

  final int rows;
  final int cols;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    for (var col = 0; col <= cols; col++) {
      final x = col * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var row = 0; row <= rows; row++) {
      final y = row * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinePainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.cols != cols ||
        oldDelegate.color != color;
  }
}

class _PlacementLayer extends StatelessWidget {
  const _PlacementLayer({
    required this.placement,
    required this.catalog,
    required this.cellWidth,
    required this.cellHeight,
  });

  final PlacedItem placement;
  final ItemCatalog catalog;
  final double cellWidth;
  final double cellHeight;

  @override
  Widget build(BuildContext context) {
    final item = catalog.itemById(placement.catalogItemId);
    if (item == null) return const SizedBox.shrink();

    final color = _parseColor(item.color) ?? Colors.blueGrey.shade200;

    return Positioned(
      left: placement.originCol * cellWidth,
      top: placement.originRow * cellHeight,
      width: item.width * cellWidth,
      height: item.height * cellHeight,
      child: IgnorePointer(
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

  Color? _parseColor(String? value) {
    if (value == null || value.isEmpty) return null;
    final hex = value.startsWith('#') ? value.substring(1) : value;
    if (hex.length == 6) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) return Color(0xFF000000 | parsed);
    }
    return null;
  }
}
