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

  test('onCellTap places item and returns true', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    final tool = PlaceTool();
    final ctx = testToolContext(controller);

    expect(tool.onCellTap(ctx), isTrue);
    expect(controller.layout.items, hasLength(1));
  });

  test('onItemTap returns false', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    controller.placeAt(0, 0);
    final item = controller.layout.items.single;
    final tool = PlaceTool();
    final ctx = testToolContext(controller);

    expect(tool.onItemTap(ctx, item), isFalse);
    expect(controller.selectedCatalogItemId, 'house');
  });

  test('onCellHover delegates to onHover callback', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    final interactionState = GridInteractionState();
    final tool = PlaceTool();
    final ctx = testToolContext(
      controller,
      row: 2,
      col: 3,
      onHover: (row, col) => interactionState.setHoverCell(row, col),
    );

    tool.onCellHover(ctx);

    expect(interactionState.hoverRow, 2);
    expect(interactionState.hoverCol, 3);
  });

  test('onCellTap reports place error via callback', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    controller.placeAt(0, 0);
    String? reportedError;
    final tool = PlaceTool(onPlaceError: (error) => reportedError = error);
    final ctx = testToolContext(controller);

    tool.onCellTap(ctx);

    expect(reportedError, isNotNull);
    expect(controller.layout.items, hasLength(1));
  });
}
