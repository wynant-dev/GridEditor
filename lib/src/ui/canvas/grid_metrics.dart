import 'dart:ui';

/// Single source of truth for grid geometry in the UI layer.
class GridMetrics {
  const GridMetrics({
    required this.rows,
    required this.cols,
    required this.size,
  });

  final int rows;
  final int cols;
  final Size size;

  double get cellWidth => size.width / cols;
  double get cellHeight => size.height / rows;

  Offset cellTopLeft(int row, int col) {
    return Offset(col * cellWidth, row * cellHeight);
  }

  Size cellSize() {
    return Size(cellWidth, cellHeight);
  }
}
