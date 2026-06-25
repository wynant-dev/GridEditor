import 'package:flutter/material.dart';

import '../../domain/geometry/grid_metrics.dart';

class FloorCell extends StatelessWidget {
  const FloorCell({
    super.key,
    required this.color,
    required this.metrics,
    required this.row,
    required this.col,
    this.opacity = 1,
  });

  final Color color;
  final GridMetrics metrics;
  final int row;
  final int col;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final topLeft = metrics.cellTopLeft(row, col);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: metrics.cellWidth,
      height: metrics.cellHeight,
      child: IgnorePointer(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final cell = ColoredBox(color: color);
    if (opacity >= 1) return cell;
    return Opacity(opacity: opacity, child: cell);
  }
}
