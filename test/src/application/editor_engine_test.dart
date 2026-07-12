import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 2, height: 2),
      CatalogItem(id: 'bank', name: 'Bank', categoryId: 'buildings', width: 2, height: 1),
    ],
  );

  group('ItemRules', () {
    test('rejects unknown catalog item', () {
      const layout = GridDocument(rows: 4, cols: 4);
      expect(
        ItemRules.itemError(
          catalog: catalog,
          layout: layout,
          catalogItemId: 'missing',
          originRow: 0,
          originCol: 0,
        ),
        'Unknown catalog item: missing',
      );
    });

    test('rejects overlapping footprints', () {
      const layout = GridDocument(
        rows: 4,
        cols: 4,
        items: [
          Item(
            id: 'p1',
            catalogItemId: 'house',
            originRow: 0,
            originCol: 0,
          ),
        ],
      );

      expect(
        ItemRules.itemError(
          catalog: catalog,
          layout: layout,
          catalogItemId: 'bank',
          originRow: 0,
          originCol: 1,
        ),
        'Item overlaps another item',
      );
    });

    test('isFootprintCellValid marks all cells valid on empty grid', () {
      const layout = GridDocument(rows: 4, cols: 4);
      const item = CatalogItem(
        id: 'house',
        name: 'House',
        categoryId: 'buildings',
        width: 2,
        height: 2,
      );

      for (var row = 0; row < 2; row++) {
        for (var col = 0; col < 2; col++) {
          expect(
            ItemRules.isFootprintCellValid(
              catalog: catalog,
              layout: layout,
              catalogItem: item,
              originRow: 0,
              originCol: 0,
              row: row,
              col: col,
            ),
            isTrue,
          );
        }
      }
    });

    test('isFootprintCellValid marks partial overlap per cell', () {
      const layout = GridDocument(
        rows: 4,
        cols: 4,
        items: [
          Item(
            id: 'p1',
            catalogItemId: 'house',
            originRow: 0,
            originCol: 0,
          ),
        ],
      );
      const item = CatalogItem(
        id: 'house',
        name: 'House',
        categoryId: 'buildings',
        width: 2,
        height: 2,
      );

      expect(
        ItemRules.isFootprintCellValid(
          catalog: catalog,
          layout: layout,
          catalogItem: item,
          originRow: 1,
          originCol: 1,
          row: 1,
          col: 1,
        ),
        isFalse,
      );
      expect(
        ItemRules.isFootprintCellValid(
          catalog: catalog,
          layout: layout,
          catalogItem: item,
          originRow: 1,
          originCol: 1,
          row: 1,
          col: 2,
        ),
        isTrue,
      );
      expect(
        ItemRules.isFootprintCellValid(
          catalog: catalog,
          layout: layout,
          catalogItem: item,
          originRow: 1,
          originCol: 1,
          row: 2,
          col: 1,
        ),
        isTrue,
      );
      expect(
        ItemRules.isFootprintCellValid(
          catalog: catalog,
          layout: layout,
          catalogItem: item,
          originRow: 1,
          originCol: 1,
          row: 2,
          col: 2,
        ),
        isTrue,
      );
    });

    test('isFootprintCellValid ignores dragged item during move', () {
      const layout = GridDocument(
        rows: 4,
        cols: 4,
        items: [
          Item(
            id: 'p1',
            catalogItemId: 'house',
            originRow: 0,
            originCol: 0,
          ),
        ],
      );
      const item = CatalogItem(
        id: 'house',
        name: 'House',
        categoryId: 'buildings',
        width: 2,
        height: 2,
      );

      for (var row = 0; row < 2; row++) {
        for (var col = 0; col < 2; col++) {
          expect(
            ItemRules.isFootprintCellValid(
              catalog: catalog,
              layout: layout,
              catalogItem: item,
              originRow: 0,
              originCol: 0,
              row: row,
              col: col,
              ignoreItemId: 'p1',
            ),
            isTrue,
          );
        }
      }
    });
  });

  group('EditorEngine', () {
    test('placeItem stores a footprint on the layout', () {
      const layout = GridDocument(rows: 4, cols: 4);
      final engine = const EditorEngine(catalog: catalog, layout: layout)
          .placeItem(
            catalogItemId: 'house',
            originRow: 0,
            originCol: 0,
            itemId: 'p1',
          );

      expect(engine.layout.items, hasLength(1));
      expect(engine.occupiesCell(row: 1, col: 1), isTrue);
    });

    test('placeItem assigns unique ids after deletion', () {
      var engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeItem(
        catalogItemId: 'house',
        originRow: 0,
        originCol: 0,
      );
      expect(engine.layout.items.single.id, 'p1');

      engine = engine.placeItem(
        catalogItemId: 'bank',
        originRow: 2,
        originCol: 0,
      );
      expect(engine.layout.items.last.id, 'p2');

      engine = engine.removeItem('p1');
      engine = engine.placeItem(
        catalogItemId: 'bank',
        originRow: 0,
        originCol: 0,
      );

      final ids = engine.layout.items.map((p) => p.id).toList();
      expect(ids, contains('p2'));
      expect(ids, contains('p3'));
      expect(ids.toSet(), hasLength(2));
    });

    test('placeItem rejects overlapping items', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeItem(
        catalogItemId: 'house',
        originRow: 0,
        originCol: 0,
      );

      expect(
        () => engine.placeItem(
          catalogItemId: 'bank',
          originRow: 0,
          originCol: 1,
        ),
        throwsStateError,
      );
    });

    test('moveItem updates item origin while preserving id', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeItem(
        catalogItemId: 'house',
        originRow: 0,
        originCol: 0,
        itemId: 'p1',
      );

      final moved = engine.moveItem(
        itemId: 'p1',
        newRow: 2,
        newCol: 2,
      );

      final item = moved.layout.items.single;
      expect(item.id, 'p1');
      expect(item.originRow, 2);
      expect(item.originCol, 2);
    });

    test('moveItem rejects overlapping items', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(
          rows: 4,
          cols: 4,
          items: [
            Item(
              id: 'p1',
              catalogItemId: 'house',
              originRow: 0,
              originCol: 0,
            ),
            Item(
              id: 'p2',
              catalogItemId: 'bank',
              originRow: 2,
              originCol: 0,
            ),
          ],
        ),
      );

      expect(
        () => engine.moveItem(
          itemId: 'p1',
          newRow: 2,
          newCol: 0,
        ),
        throwsStateError,
      );
    });

    test('moveItem rejects out-of-bounds target', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeItem(
        catalogItemId: 'house',
        originRow: 0,
        originCol: 0,
        itemId: 'p1',
      );

      expect(
        () => engine.moveItem(
          itemId: 'p1',
          newRow: 3,
          newCol: 3,
        ),
        throwsStateError,
      );
    });

    test('moveItem allows no-op move to same origin', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeItem(
        catalogItemId: 'house',
        originRow: 1,
        originCol: 1,
        itemId: 'p1',
      );

      final moved = engine.moveItem(
        itemId: 'p1',
        newRow: 1,
        newCol: 1,
      );

      expect(moved.layout.items.single.originRow, 1);
      expect(moved.layout.items.single.originCol, 1);
    });

    test('layout round-trips through JSON', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 3, cols: 3),
      ).placeItem(
        catalogItemId: 'bank',
        originRow: 1,
        originCol: 1,
        itemId: 'p1',
      );

      final restored = EditorEngine.fromLayoutJson(
        catalog: catalog,
        source: engine.layoutToJson(),
      );
      expect(restored.layout.items.single.catalogItemId, 'bank');
    });
  });

  group('Sticker operations', () {
    const stickerCatalog = Catalog(
      id: 'test',
      name: 'Test',
      stickers: [
        CatalogSticker(
          id: 'tree',
          name: 'Tree',
          iconName: 'park',
        ),
      ],
    );
    const origin = Offset.zero;
    const cellSize = 48.0;

    test('placeSticker appends sticker within bounds', () {
      final engine = const EditorEngine(
        catalog: stickerCatalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeSticker(
        catalogStickerId: 'tree',
        x: 24,
        y: 24,
        cellSize: cellSize,
        origin: origin,
      );

      expect(engine.layout.stickers, hasLength(1));
      expect(engine.layout.stickers.single.catalogStickerId, 'tree');
      expect(engine.layout.stickers.single.id, 's1');
    });

    test('placeSticker rejects out of bounds', () {
      final engine = const EditorEngine(
        catalog: stickerCatalog,
        layout: GridDocument(rows: 4, cols: 4),
      );

      expect(
        () => engine.placeSticker(
          catalogStickerId: 'tree',
          x: 5,
          y: 24,
          cellSize: cellSize,
          origin: origin,
        ),
        throwsStateError,
      );
    });

    test('moveSticker updates position', () {
      final engine = const EditorEngine(
        catalog: stickerCatalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeSticker(
        catalogStickerId: 'tree',
        x: 24,
        y: 24,
        cellSize: cellSize,
        origin: origin,
        stickerId: 's1',
      );

      final moved = engine.moveSticker(
        stickerId: 's1',
        x: 72,
        y: 72,
        cellSize: cellSize,
        origin: origin,
      );

      expect(moved.layout.stickers.single.x, 72);
      expect(moved.layout.stickers.single.y, 72);
    });

    test('removeSticker removes sticker', () {
      final engine = const EditorEngine(
        catalog: stickerCatalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeSticker(
        catalogStickerId: 'tree',
        x: 24,
        y: 24,
        cellSize: cellSize,
        origin: origin,
        stickerId: 's1',
      );

      final updated = engine.removeSticker('s1');

      expect(updated.layout.stickers, isEmpty);
    });
  });

  test('Catalog round-trips through JSON', () {
    const catalog = Catalog(
      id: 'ddv',
      name: 'DDV',
      items: [
        CatalogItem(
          id: 'house',
          name: 'House',
          categoryId: 'buildings',
          width: 4,
          height: 4,
          color: '#E53935',
        ),
      ],
    );

    final restored = Catalog.fromJson(catalog.toJson());
    expect(restored.name, 'DDV');
    expect(restored.items.single.width, 4);
  });
}
