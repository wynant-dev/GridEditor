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
    expect(controller.selectedItemId, isNull);
    expect(controller.selectedFloorId, isNull);
    expect(notified, 1);
  });

  test('placeAt updates layout when item is selected', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');

    final error = controller.placeAt(0, 0);

    expect(error, isNull);
    expect(controller.layout.placements, hasLength(1));
  });

  test('placeAt centers item on anchor cell', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');

    controller.placeAt(5, 5);

    final placement = controller.layout.placements.single;
    expect(placement.originRow, 4);
    expect(placement.originCol, 4);
  });

  test('placeAt returns error message on invalid placement', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);

    final error = controller.placeAt(0, 1);

    expect(error, isNotNull);
  });

  test('removePlacement clears placement from layout', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;

    controller.removePlacement(placement);

    expect(controller.layout.placements, isEmpty);
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

    controller.selectFloor('water');
    expect(controller.selectedFloorId, 'water');
    expect(controller.selectedItemId, isNull);

    controller.selectItem('b');
    expect(controller.selectedItemId, 'b');
    expect(controller.selectedFloorId, isNull);
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

    controller.selectFloor('grass');
    final error = controller.paintFloorAt(3, 4);

    expect(error, isNull);
    expect(controller.layout.floorIdAt(3, 4), 'grass');
  });

  test('selectFloor switches active tool to FloorTool', () {
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

    controller.selectFloor('water');

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

    controller.selectFloor('water');
    controller.selectItem('a');

    expect(controller.toolManager.activeTool, isA<PlaceTool>());
  });

  test('movePlacement updates layout and preserves selection', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    controller.selectPlacement(placement.id);

    final moved = controller.movePlacement(
      placementId: placement.id,
      newRow: 2,
      newCol: 2,
    );

    expect(moved, isTrue);
    expect(controller.layout.placements.single.originRow, 2);
    expect(controller.layout.placements.single.originCol, 2);
    expect(controller.selectedPlacementId, placement.id);
  });

  test('movePlacement returns false for invalid move', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;

    final moved = controller.movePlacement(
      placementId: placement.id,
      newRow: 63,
      newCol: 63,
    );

    expect(moved, isFalse);
    expect(controller.layout.placements.single.originRow, 0);
    expect(controller.layout.placements.single.originCol, 0);
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

    controller.selectItem('a');
    controller.selectItem('b');

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

    controller.selectItem('a');
    controller.placeAt(0, 0);
    controller.selectItem('b');
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

    controller.selectFloor('sand');
    controller.paintFloorAt(0, 0);
    controller.selectFloor('grass');
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

    controller.selectItem('a');
    controller.placeAt(0, 0);
    controller.selectItem('b');
    controller.placeAt(2, 0);
    controller.selectItem('c');
    controller.placeAt(4, 0);
    controller.selectFloor('sand');
    controller.paintFloorAt(0, 1);
    controller.selectItem('a');
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

    controller.selectItem('a');
    controller.placeAt(0, 0);
    controller.selectFloor('sand');
    controller.paintFloorAt(1, 0);
    controller.reselectFromHistory(
      const SelectionHistoryEntry(kind: SelectionKind.item, id: 'a'),
    );

    expect(controller.selectedItemId, 'a');
    expect(controller.selectedFloorId, isNull);
  });
}
