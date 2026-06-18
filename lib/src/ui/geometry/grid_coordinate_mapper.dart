import 'dart:ui';

import 'grid_metrics.dart';

/// Converts pointer positions on the canvas into grid cell coordinates.
///
/// Centralizes layout math so future zoom, pan, and transform support can be
/// added here without changing hover or input handling call sites.
class GridCoordinateMapper {
  const GridCoordinateMapper(this.metrics);

  final GridMetrics metrics;

  (int row, int col) fromLocalPosition(Offset position) {
    final world = metrics.screenToWorld(position);

    final row = (world.dy / metrics.cellHeight)
        .floor()
        .clamp(0, metrics.rows - 1);
    final col = (world.dx / metrics.cellWidth)
        .floor()
        .clamp(0, metrics.cols - 1);

    return (row, col);
  }
}
