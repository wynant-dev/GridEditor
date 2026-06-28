import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

import 'grid_test_helpers.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 1, height: 1),
    ],
  );

  test('onCellTap places item and returns true', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    final tool = DefaultTool();
    final context = testToolContext(controller);

    final handled = tool.onCellTap(context);

    expect(handled, isTrue);
    expect(controller.layout.placements, hasLength(1));
  });

  test('onPlacementTap selects placement and returns true', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final tool = DefaultTool();

    final handled = tool.onPlacementTap(testToolContext(controller), placement);

    expect(handled, isTrue);
    expect(controller.selectedPlacementId, placement.id);
  });

  test('onCellHover updates hover state via onHover callback', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
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
