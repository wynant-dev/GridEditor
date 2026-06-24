import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', width: 2, height: 2),
    ],
  );

  test('loadCatalog updates engine and selects first item', () {
    final controller = EditorController();
    var notified = 0;
    controller.addListener(() => notified++);

    controller.loadCatalog(catalog);

    expect(controller.catalog, catalog);
    expect(controller.selectedItemId, 'house');
    expect(notified, 1);
  });

  test('placeAt updates layout when item is selected', () {
    final controller = EditorController()..loadCatalog(catalog);

    final error = controller.placeAt(0, 0);

    expect(error, isNull);
    expect(controller.layout.placements, hasLength(1));
  });

  test('placeAt centers item on anchor cell', () {
    final controller = EditorController()..loadCatalog(catalog);

    controller.placeAt(5, 5);

    final placement = controller.layout.placements.single;
    expect(placement.originRow, 4);
    expect(placement.originCol, 4);
  });

  test('placeAt returns error message on invalid placement', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.placeAt(0, 0);

    final error = controller.placeAt(0, 1);

    expect(error, isNotNull);
  });

  test('removePlacement clears placement from layout', () {
    final controller = EditorController()..loadCatalog(catalog);
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
            CatalogItem(id: 'a', name: 'A', width: 1, height: 1),
            CatalogItem(id: 'b', name: 'B', width: 1, height: 1),
          ],
        ),
      );

    controller.selectItem('b');

    expect(controller.selectedItemId, 'b');
  });

  test('movePlacement updates layout and preserves selection', () {
    final controller = EditorController()..loadCatalog(catalog);
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
    final controller = EditorController()..loadCatalog(catalog);
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
}
