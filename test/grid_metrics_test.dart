import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  group('GridMetrics', () {
    const metrics = GridMetrics(
      rows: 4,
      cols: 8,
      size: Size(800, 400),
    );

    test('computes cell dimensions', () {
      expect(metrics.cellWidth, 100);
      expect(metrics.cellHeight, 100);
    });

    test('cellTopLeft returns pixel offset for grid cell', () {
      expect(metrics.cellTopLeft(0, 0), const Offset(0, 0));
      expect(metrics.cellTopLeft(2, 3), const Offset(300, 200));
    });

    test('cellSize returns single-cell dimensions', () {
      expect(metrics.cellSize(), const Size(100, 100));
    });
  });
}
