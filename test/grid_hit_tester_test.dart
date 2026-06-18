import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = ItemCatalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', width: 1, height: 1),
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

    final hit = hitTester.classifyTap(const Offset(50, 50));

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

    final hit = hitTester.classifyTap(const Offset(150, 150));

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

    expect(hitTester.cellAt(const Offset(50, 50)), (0, 0));
    expect(hitTester.cellAt(const Offset(150, 150)), (1, 1));
  });
}
