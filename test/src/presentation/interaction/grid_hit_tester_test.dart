import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

import '../../../helpers/grid_test_helpers.dart';

void main() {
    final catalog = testCatalog(
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

  test('classifyTap returns ItemHit when pointer is over item', () {
    const item = Item(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    const document = GridDocument(
      rows: 2,
      cols: 2,
      items: [item],
    );
    final hitTester = GridHitTester(
      mapper: mapper,
      document: document,
      catalog: catalog,
    );

    final hit = hitTester.classifyTap(cellCenter(metrics, 0, 0));

    expect(hit, isA<ItemHit>());
    final itemHit = hit as ItemHit;
    expect(itemHit.item, item);
    expect(itemHit.row, 0);
    expect(itemHit.col, 0);
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

  test('classifyTap returns StickerHit over ItemHit', () {
    final catalogWithStickers = testCatalog(
      items: [
        CatalogItem(id: 'house', name: 'House', width: 1, height: 1),
      ],
      stickers: [
        CatalogSticker(
          id: 'tree',
          name: 'Tree',
          iconName: 'park',
        ),
      ],
    );
    const item = Item(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    final stickerCenter = cellCenter(metrics, 0, 0);
    final document = GridDocument(
      rows: 2,
      cols: 2,
      items: const [item],
      stickers: [
        Sticker(
          id: 's1',
          catalogStickerId: 'tree',
          x: stickerCenter.dx,
          y: stickerCenter.dy,
        ),
      ],
    );
    final hitTester = GridHitTester(
      mapper: mapper,
      document: document,
      catalog: catalogWithStickers,
    );

    final hit = hitTester.classifyTap(stickerCenter);

    expect(hit, isA<StickerHit>());
  });
}
