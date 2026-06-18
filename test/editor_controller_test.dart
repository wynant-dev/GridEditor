import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = ItemCatalog(
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
        const ItemCatalog(
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

  test('setHoverCell updates hover state and notifies listeners', () {
    final controller = EditorController()..loadCatalog(catalog);
    var notified = 0;
    controller.addListener(() => notified++);

    controller.setHoverCell(2, 3);

    expect(controller.hoverRow, 2);
    expect(controller.hoverCol, 3);
    expect(notified, 1);

    controller.setHoverCell(2, 3);
    expect(notified, 1);

    controller.setHoverCell(null, null);
    expect(controller.hoverRow, isNull);
    expect(controller.hoverCol, isNull);
    expect(notified, 2);
  });

  test('setHoverCell does not modify engine layout', () {
    final controller = EditorController()..loadCatalog(catalog);
    final layoutBefore = controller.layout;

    controller.setHoverCell(1, 1);

    expect(controller.layout, layoutBefore);
    expect(controller.layout.placements, isEmpty);
  });
}
