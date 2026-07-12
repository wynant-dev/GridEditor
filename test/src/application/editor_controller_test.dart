import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 2, height: 2),
    ],
  );

  test('loadCatalog updates engine without selecting an item', () {
    final controller = EditorController();
    var notified = 0;
    controller.addListener(() => notified++);

    controller.loadCatalog(catalog);

    expect(controller.catalog, catalog);
    expect(controller.selectedCatalogItemId, isNull);
    expect(controller.selectedCatalogFloorId, isNull);
    expect(notified, 1);
  });

  test('placeAt updates layout when item is selected', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');

    final error = controller.placeAt(0, 0);

    expect(error, isNull);
    expect(controller.layout.items, hasLength(1));
  });

  test('placeAt centers item on anchor cell', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');

    controller.placeAt(5, 5);

    final item = controller.layout.items.single;
    expect(item.originRow, 4);
    expect(item.originCol, 4);
  });

  test('placeAt returns error message when place is invalid', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    controller.placeAt(0, 0);

    final error = controller.placeAt(0, 1);

    expect(error, isNotNull);
  });

  test('removeItem clears item from layout', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    controller.placeAt(0, 0);
    final item = controller.layout.items.single;

    controller.removeItem(item);

    expect(controller.layout.items, isEmpty);
  });

  test('selectItem updates selection', () {
    final controller = EditorController()
      ..loadCatalog(
        const Catalog(
          id: 'test',
          name: 'Test',
          items: [
            CatalogItem(id: 'a', name: 'A', categoryId: 'buildings', width: 1, height: 1),
            CatalogItem(id: 'b', name: 'B', categoryId: 'buildings', width: 1, height: 1),
          ],
          floors: [
            CatalogFloor(id: 'water', name: 'Water', color: '#42A5F5'),
          ],
        ),
      );

    controller.selectCatalogFloor('water');
    expect(controller.selectedCatalogFloorId, 'water');
    expect(controller.selectedCatalogItemId, isNull);

    controller.selectCatalogItem('b');
    expect(controller.selectedCatalogItemId, 'b');
    expect(controller.selectedCatalogFloorId, isNull);
  });

  test('paintFloorAt updates layout when floor is selected', () {
    final controller = EditorController()
      ..loadCatalog(
        const Catalog(
          id: 'test',
          name: 'Test',
          floors: [
            CatalogFloor(id: 'grass', name: 'Grass', color: '#66BB6A'),
          ],
        ),
      );

    controller.selectCatalogFloor('grass');
    final error = controller.paintFloorAt(3, 4);

    expect(error, isNull);
    expect(controller.layout.floorIdAt(3, 4), 'grass');
  });

  test('selectCatalogFloor switches active tool to FloorTool', () {
    final controller = EditorController()
      ..loadCatalog(
        const Catalog(
          id: 'test',
          name: 'Test',
          floors: [
            CatalogFloor(id: 'water', name: 'Water', color: '#42A5F5'),
          ],
        ),
      );

    controller.selectCatalogFloor('water');

    expect(controller.toolManager.activeTool, isA<FloorTool>());
  });

  test('selectItem switches active tool to PlaceTool', () {
    final controller = EditorController()
      ..loadCatalog(
        const Catalog(
          id: 'test',
          name: 'Test',
          items: [
            CatalogItem(id: 'a', name: 'A', categoryId: 'buildings', width: 1, height: 1),
          ],
          floors: [
            CatalogFloor(id: 'water', name: 'Water', color: '#42A5F5'),
          ],
        ),
      );

    controller.selectCatalogFloor('water');
    controller.selectCatalogItem('a');

    expect(controller.toolManager.activeTool, isA<PlaceTool>());
  });

  test('moveItem updates layout and preserves selection', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    controller.placeAt(0, 0);
    final item = controller.layout.items.single;
    controller.selectItem(item.id);

    final moved = controller.moveItem(
      itemId: item.id,
      newRow: 2,
      newCol: 2,
    );

    expect(moved, isTrue);
    expect(controller.layout.items.single.originRow, 2);
    expect(controller.layout.items.single.originCol, 2);
    expect(controller.selectedItemId, item.id);
  });

  test('moveItem returns false for invalid move', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    controller.placeAt(0, 0);
    final item = controller.layout.items.single;

    final moved = controller.moveItem(
      itemId: item.id,
      newRow: 129,
      newCol: 129,
    );

    expect(moved, isFalse);
    expect(controller.layout.items.single.originRow, 0);
    expect(controller.layout.items.single.originCol, 0);
  });

  test('selectItem does not push to selection history', () {
    final controller = EditorController()
      ..loadCatalog(
        const Catalog(
          id: 'test',
          name: 'Test',
          items: [
            CatalogItem(id: 'a', name: 'A', categoryId: 'buildings', width: 1, height: 1),
            CatalogItem(id: 'b', name: 'B', categoryId: 'buildings', width: 1, height: 1),
          ],
        ),
      );

    controller.selectCatalogItem('a');
    controller.selectCatalogItem('b');

    expect(controller.selectionHistory, isEmpty);
  });

  test('placeAt pushes to selection history', () {
    final controller = EditorController()
      ..loadCatalog(
        const Catalog(
          id: 'test',
          name: 'Test',
          items: [
            CatalogItem(id: 'a', name: 'A', categoryId: 'buildings', width: 1, height: 1),
            CatalogItem(id: 'b', name: 'B', categoryId: 'buildings', width: 1, height: 1),
          ],
        ),
      );

    controller.selectCatalogItem('a');
    controller.placeAt(0, 0);
    controller.selectCatalogItem('b');
    controller.placeAt(2, 0);

    expect(controller.selectionHistory, [
      const SelectionHistoryEntry(kind: SelectionKind.item, id: 'b'),
      const SelectionHistoryEntry(kind: SelectionKind.item, id: 'a'),
    ]);
  });

  test('paintFloorAt pushes to selection history', () {
    final controller = EditorController()
      ..loadCatalog(
        const Catalog(
          id: 'test',
          name: 'Test',
          floors: [
            CatalogFloor(id: 'sand', name: 'Sand', color: '#FFD54F'),
            CatalogFloor(id: 'grass', name: 'Grass', color: '#66BB6A'),
          ],
        ),
      );

    controller.selectCatalogFloor('sand');
    controller.paintFloorAt(0, 0);
    controller.selectCatalogFloor('grass');
    controller.paintFloorAt(1, 0);

    expect(controller.selectionHistory, [
      const SelectionHistoryEntry(kind: SelectionKind.floor, id: 'grass'),
      const SelectionHistoryEntry(kind: SelectionKind.floor, id: 'sand'),
    ]);
  });

  test('selection history dedupes and caps at 3', () {
    final controller = EditorController()
      ..loadCatalog(
        const Catalog(
          id: 'test',
          name: 'Test',
          items: [
            CatalogItem(id: 'a', name: 'A', categoryId: 'buildings', width: 1, height: 1),
            CatalogItem(id: 'b', name: 'B', categoryId: 'buildings', width: 1, height: 1),
            CatalogItem(id: 'c', name: 'C', categoryId: 'buildings', width: 1, height: 1),
            CatalogItem(id: 'd', name: 'D', categoryId: 'buildings', width: 1, height: 1),
          ],
          floors: [
            CatalogFloor(id: 'sand', name: 'Sand', color: '#FFD54F'),
          ],
        ),
      );

    controller.selectCatalogItem('a');
    controller.placeAt(0, 0);
    controller.selectCatalogItem('b');
    controller.placeAt(2, 0);
    controller.selectCatalogItem('c');
    controller.placeAt(4, 0);
    controller.selectCatalogFloor('sand');
    controller.paintFloorAt(0, 1);
    controller.selectCatalogItem('a');
    controller.placeAt(6, 0);

    expect(controller.selectionHistory, hasLength(3));
    expect(controller.selectionHistory.first.id, 'a');
    expect(controller.selectionHistory.map((e) => e.id), ['a', 'sand', 'c']);
  });

  test('reselectFromHistory selects item or floor', () {
    final controller = EditorController()
      ..loadCatalog(
        const Catalog(
          id: 'test',
          name: 'Test',
          items: [
            CatalogItem(id: 'a', name: 'A', categoryId: 'buildings', width: 1, height: 1),
          ],
          floors: [
            CatalogFloor(id: 'sand', name: 'Sand', color: '#FFD54F'),
          ],
        ),
      );

    controller.selectCatalogItem('a');
    controller.placeAt(0, 0);
    controller.selectCatalogFloor('sand');
    controller.paintFloorAt(1, 0);
    controller.reselectFromHistory(
      const SelectionHistoryEntry(kind: SelectionKind.item, id: 'a'),
    );

    expect(controller.selectedCatalogItemId, 'a');
    expect(controller.selectedCatalogFloorId, isNull);
  });

  group('Sticker selection', () {
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

    test('selectCatalogSticker switches active tool to StickerTool', () {
      final controller = EditorController()..loadCatalog(stickerCatalog);

      controller.selectCatalogSticker('tree');

      expect(controller.selectedCatalogStickerId, 'tree');
      expect(controller.toolManager.activeTool, isA<StickerTool>());
    });

    test('selectSticker clears item and catalog selections', () {
      final controller = EditorController()
        ..loadCatalog(stickerCatalog)
        ..selectCatalogSticker('tree');

      controller.selectSticker('s1');

      expect(controller.selectedStickerId, 's1');
      expect(controller.selectedCatalogStickerId, isNull);
      expect(controller.selectedCatalogItemId, isNull);
    });

    test('selectCatalogItem clears sticker selection', () {
      final controller = EditorController()
        ..loadCatalog(catalog)
        ..selectSticker('s1');

      controller.selectCatalogItem('house');

      expect(controller.selectedStickerId, isNull);
      expect(controller.selectedCatalogItemId, 'house');
    });

    test('placeStickerAt places sticker at world center', () {
      final controller = EditorController()..loadCatalog(stickerCatalog);
      controller.selectCatalogSticker('tree');

      final error = controller.placeStickerAt(
        worldCenter: const Offset(24, 24),
        cellSize: 48,
        origin: Offset.zero,
      );

      expect(error, isNull);
      expect(controller.layout.stickers, hasLength(1));
    });
  });

  group('action log', () {
    test('records successful and failed place attempts', () {
      final controller = EditorController()
        ..loadCatalog(catalog)
        ..selectCatalogItem('house');

      expect(controller.placeAt(0, 0), isNull);
      expect(controller.placeAt(0, 0), isNotNull);

      final entries = controller.actionLog.entries;
      expect(entries, hasLength(2));
      expect(entries[0].success, isFalse);
      expect(entries[0].message, startsWith('Place failed - House (0, 0):'));
      expect(entries[1].success, isTrue);
      expect(entries[1].message, 'Placed - House (0, 0)');
    });

    test('records delete and move actions', () {
      final controller = EditorController()
        ..loadCatalog(catalog)
        ..selectCatalogItem('house')
        ..placeAt(0, 0);

      final item = controller.layout.items.single;
      controller.moveItem(
        itemId: item.id,
        newRow: 2,
        newCol: 2,
      );
      controller.removeItem(item);

      final messages = controller.actionLog.entries.map((e) => e.message).toList();
      expect(messages[0], 'Deleted - House (2, 2)');
      expect(messages[1], 'Moved - House (2, 2)');
      expect(messages[2], 'Placed - House (0, 0)');
    });

    test('clears on loadCatalog', () {
      final controller = EditorController()
        ..loadCatalog(catalog)
        ..selectCatalogItem('house')
        ..placeAt(0, 0);

      controller.loadCatalog(catalog);

      expect(controller.actionLog.entries, isEmpty);
    });
  });
}
