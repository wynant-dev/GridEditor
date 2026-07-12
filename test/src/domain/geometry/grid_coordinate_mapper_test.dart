import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

import '../../../helpers/grid_test_helpers.dart';

void main() {
  group('GridCoordinateMapper', () {
    test('maps position to grid cell', () {
      final metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: const Size(400, 400),
      );
      final mapper = GridCoordinateMapper(metrics);

      expect(mapper.fromLocalPosition(cellCenter(metrics, 0, 0)), (0, 0));
      expect(mapper.fromLocalPosition(cellCenter(metrics, 2, 1)), (2, 1));
      expect(mapper.fromLocalPosition(cellCenter(metrics, 3, 3)), (3, 3));
    });

    test('clamps position outside grid bounds', () {
      final metrics = GridMetrics(
        rows: 2,
        cols: 2,
        size: const Size(200, 200),
      );
      final mapper = GridCoordinateMapper(metrics);

      expect(mapper.fromLocalPosition(const Offset(-10, -10)), (0, 0));
      expect(mapper.fromLocalPosition(const Offset(500, 500)), (1, 1));
    });

    test('maps screen position through viewport transform', () {
      final metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: const Size(400, 400),
        transform: const ViewportTransform(offset: Offset(100, 50), zoom: 2.0),
      );
      final mapper = GridCoordinateMapper(metrics);

      expect(mapper.fromLocalPosition(const Offset(100, 50)), (0, 0));
      expect(mapper.fromLocalPosition(const Offset(452, 498)), (2, 1));
    });

    test('fromWorldPosition maps world coordinates directly', () {
      final metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: const Size(400, 400),
      );
      final mapper = GridCoordinateMapper(metrics);

      expect(mapper.fromWorldPosition(const Offset(50, 50)), (0, 0));
      expect(mapper.fromWorldPosition(cellCenter(metrics, 2, 1)), (2, 1));
      expect(mapper.fromWorldPosition(const Offset(-10, -10)), (0, 0));
    });

    test('hitTestItem returns topmost item at position', () {
      final metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: const Size(400, 400),
      );
      final mapper = GridCoordinateMapper(metrics);
      const catalog = Catalog(
        id: 'test',
        name: 'Test',
        items: [
          CatalogItem(id: 'a', name: 'A', categoryId: 'buildings', width: 1, height: 1),
          CatalogItem(id: 'b', name: 'B', categoryId: 'buildings', width: 2, height: 2),
        ],
      );
      const document = GridDocument(
        rows: 4,
        cols: 4,
        items: [
          Item(id: 'p1', catalogItemId: 'a', originRow: 0, originCol: 0),
          Item(id: 'p2', catalogItemId: 'b', originRow: 0, originCol: 0),
        ],
      );

      final hit = mapper.hitTestItem(
        cellCenter(metrics, 0, 0),
        document,
        catalog,
      );

      expect(hit?.id, 'p2');
    });

    test('hitTestItem returns null for empty cell', () {
      final metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: const Size(400, 400),
      );
      final mapper = GridCoordinateMapper(metrics);
      const catalog = Catalog(
        id: 'test',
        name: 'Test',
        items: [
          CatalogItem(id: 'a', name: 'A', categoryId: 'buildings', width: 1, height: 1),
        ],
      );
      const document = GridDocument(
        rows: 4,
        cols: 4,
        items: [
          Item(id: 'p1', catalogItemId: 'a', originRow: 0, originCol: 0),
        ],
      );

      expect(
        mapper.hitTestItem(cellCenter(metrics, 3, 3), document, catalog),
        isNull,
      );
    });
  });
}
