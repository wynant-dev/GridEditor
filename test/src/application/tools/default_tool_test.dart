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
    final tool = DefaultTool();
    final context = testToolContext(controller);

    final handled = tool.onCellTap(context);

    expect(handled, isTrue);
    expect(controller.layout.items, hasLength(1));
  });

  test('onItemTap selects item and returns true', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    controller.placeAt(0, 0);
    final item = controller.layout.items.single;
    final tool = DefaultTool();

    final handled = tool.onItemTap(testToolContext(controller), item);

    expect(handled, isTrue);
    expect(controller.selectedItemId, item.id);
  });

  test('onCellHover updates hover state via onHover callback', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    final interactionState = GridInteractionState();
    final tool = DefaultTool();
    final context = testToolContext(
      controller,
      row: 2,
      col: 3,
      onHover: (row, col) => interactionState.setHoverCell(row, col),
    );

    tool.onCellHover(context);

    expect(interactionState.hoverRow, 2);
    expect(interactionState.hoverCol, 3);
  });
}
