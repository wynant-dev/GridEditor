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

  test('selectPlacement updates selection and notifies listeners', () {
    final controller = EditorController()..loadCatalog(catalog);
    var notified = 0;
    controller.addListener(() => notified++);

    controller.selectPlacement('p1');

    expect(controller.selectedPlacementId, 'p1');
    expect(controller.selection.selectedPlacementId, 'p1');
    expect(controller.selectedItemId, isNull);
    expect(notified, 1);
  });

  test('selectPlacement clears catalog item selection', () {
    final controller = EditorController()..loadCatalog(catalog);

    expect(controller.selectedItemId, 'house');

    controller.selectPlacement('p1');

    expect(controller.selectedItemId, isNull);
  });

  test('selectItem clears placement selection', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectPlacement('p1');

    controller.selectItem('house');

    expect(controller.selectedPlacementId, isNull);
    expect(controller.selectedItemId, 'house');
  });

  test('clearSelection resets selection', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectPlacement('p1');

    controller.clearSelection();

    expect(controller.selectedPlacementId, isNull);
  });

  test('removePlacement clears selection when removed placement was selected',
      () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    controller.selectPlacement(placement.id);

    controller.removePlacement(placement);

    expect(controller.selectedPlacementId, isNull);
    expect(controller.layout.placements, isEmpty);
  });
}
