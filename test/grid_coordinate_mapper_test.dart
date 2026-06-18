import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  group('GridCoordinateMapper', () {
    test('maps position to grid cell', () {
      const metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: Size(400, 400),
      );
      const mapper = GridCoordinateMapper(metrics);

      expect(mapper.fromLocalPosition(const Offset(50, 50)), (0, 0));
      expect(mapper.fromLocalPosition(const Offset(150, 250)), (2, 1));
      expect(mapper.fromLocalPosition(const Offset(399, 399)), (3, 3));
    });

    test('clamps position outside grid bounds', () {
      const metrics = GridMetrics(
        rows: 2,
        cols: 2,
        size: Size(200, 200),
      );
      const mapper = GridCoordinateMapper(metrics);

      expect(mapper.fromLocalPosition(const Offset(-10, -10)), (0, 0));
      expect(mapper.fromLocalPosition(const Offset(500, 500)), (1, 1));
    });

    test('maps screen position through viewport transform', () {
      const metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: Size(400, 400),
        transform: ViewportTransform(offset: Offset(100, 50), zoom: 2.0),
      );
      const mapper = GridCoordinateMapper(metrics);

      expect(mapper.fromLocalPosition(const Offset(100, 50)), (0, 0));
      expect(mapper.fromLocalPosition(const Offset(300, 450)), (2, 1));
    });
  });
}
