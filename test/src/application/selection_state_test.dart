import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

import '../../helpers/grid_test_helpers.dart';

void main() {
    final catalog = testCatalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', width: 1, height: 1),
    ],
  );

  test('selectItem updates selection and notifies listeners', () {
    final controller = EditorController()..loadCatalog(catalog);
    var notified = 0;
    controller.addListener(() => notified++);

    controller.selectItem('p1');

    expect(controller.selectedItemId, 'p1');
    expect(controller.selection.selectedItemId, 'p1');
    expect(controller.selectedCatalogItemId, isNull);
    expect(notified, 1);
  });

  test('selectItem clears catalog item selection', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');

    expect(controller.selectedCatalogItemId, 'house');

    controller.selectItem('p1');

    expect(controller.selectedCatalogItemId, isNull);
    expect(controller.selectedItemId, 'p1');
  });

  test('selectCatalogItem clears grid item selection', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('p1');

    controller.selectCatalogItem('house');

    expect(controller.selectedItemId, isNull);
    expect(controller.selectedCatalogItemId, 'house');
  });

  test('clearSelection resets selection', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('p1');

    controller.clearSelection();

    expect(controller.selectedItemId, isNull);
  });

  test('removeItem clears selection when removed item was selected', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    controller.placeAt(0, 0);
    final item = controller.layout.items.single;
    controller.selectItem(item.id);

    controller.removeItem(item);

    expect(controller.selectedItemId, isNull);
    expect(controller.layout.items, isEmpty);
  });
}
