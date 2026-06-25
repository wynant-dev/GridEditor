import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

import 'grid_test_helpers.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 1, height: 1),
    ],
  );

  final metrics = GridMetrics(
    rows: 2,
    cols: 2,
    size: const Size(200, 200),
  );
  final mapper = GridCoordinateMapper(metrics);

  test('classifyTap returns PlacementHit when pointer is over placement', () {
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    const document = GridDocument(
      rows: 2,
      cols: 2,
      placements: [placement],
    );
    final hitTester = GridHitTester(
      mapper: mapper,
      document: document,
      catalog: catalog,
    );

    final hit = hitTester.classifyTap(cellCenter(metrics, 0, 0));

    expect(hit, isA<PlacementHit>());
    final placementHit = hit as PlacementHit;
    expect(placementHit.placement, placement);
    expect(placementHit.row, 0);
    expect(placementHit.col, 0);
  });

  test('classifyTap returns CellHit when pointer is on empty cell', () {
    const document = GridDocument(rows: 2, cols: 2);
    final hitTester = GridHitTester(
      mapper: mapper,
      document: document,
      catalog: catalog,
    );

    final hit = hitTester.classifyTap(cellCenter(metrics, 1, 1));

    expect(hit, isA<CellHit>());
    final cellHit = hit as CellHit;
    expect(cellHit.row, 1);
    expect(cellHit.col, 1);
  });

  test('cellAt returns grid coordinates for pointer position', () {
    const document = GridDocument(rows: 2, cols: 2);
    final hitTester = GridHitTester(
      mapper: mapper,
      document: document,
      catalog: catalog,
    );

    expect(hitTester.cellAt(cellCenter(metrics, 0, 0)), (0, 0));
    expect(hitTester.cellAt(cellCenter(metrics, 1, 1)), (1, 1));
  });
}
