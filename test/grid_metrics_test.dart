import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  group('GridMetrics', () {
    final metrics = GridMetrics(
      rows: 4,
      cols: 8,
      size: const Size(800, 400),
    );

    test('computes square cell dimensions', () {
      expect(metrics.cellWidth, 100);
      expect(metrics.cellHeight, 100);
      expect(metrics.cellWidth, metrics.cellHeight);
    });

    test('keeps cells square when viewport aspect ratio differs from grid', () {
      final wide = GridMetrics(
        rows: 4,
        cols: 8,
        size: const Size(800, 600),
      );

      expect(wide.cellWidth, 75);
      expect(wide.cellHeight, 75);
      expect(wide.gridSize, const Size(600, 300));
      expect(wide.origin, const Offset(100, 150));
    });

    test('cellTopLeft returns pixel offset for grid cell', () {
      expect(metrics.cellTopLeft(0, 0), const Offset(0, 0));
      expect(metrics.cellTopLeft(2, 3), const Offset(300, 200));
    });

    test('cellSize returns single-cell dimensions', () {
      expect(metrics.cellSize(), const Size(100, 100));
    });

    test('screenToWorld inverts viewport transform', () {
      final metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: const Size(400, 400),
        transform: const ViewportTransform(offset: Offset(100, 50), zoom: 2.0),
      );

      expect(metrics.screenToWorld(const Offset(100, 50)), const Offset(0, 0));
      expect(metrics.screenToWorld(const Offset(300, 250)), const Offset(100, 100));
    });
  });
}
