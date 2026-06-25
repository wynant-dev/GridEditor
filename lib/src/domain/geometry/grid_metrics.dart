import 'dart:ui';

import 'viewport_transform.dart';

/// Single source of truth for grid geometry in the UI layer.
class GridMetrics {
  static const double defaultCellSize = 48.0;

  GridMetrics({
    required this.rows,
    required this.cols,
    required this.size,
    this.cellSize = defaultCellSize,
    this.transform = const ViewportTransform(),
  }) : cellWidth = cellSize,
       cellHeight = cellSize,
       gridSize = Size(cols * cellSize, rows * cellSize),
       origin = Offset(
         (size.width - cols * cellSize) / 2,
         (size.height - rows * cellSize) / 2,
       );

  final int rows;
  final int cols;

  /// Viewport/layout size used for centering; not the grid extent.
  final Size size;
  final double cellSize;
  final ViewportTransform transform;
  final double cellWidth;
  final double cellHeight;
  final Size gridSize;
  final Offset origin;

  Offset cellTopLeft(int row, int col) {
    return origin + Offset(col * cellSize, row * cellSize);
  }

  Size get cellDimensions => Size(cellWidth, cellHeight);

  Offset screenToWorld(Offset position) {
    return transform.screenToWorld(position);
  }
}
