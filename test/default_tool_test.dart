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

  GridToolContext ctx(EditorController controller) => GridToolContext(
    row: 0,
    col: 0,
    controller: controller,
    engine: controller.engine,
  );

  test('onCellTap places item and returns true', () {
    final controller = EditorController()..loadCatalog(catalog);
    final tool = DefaultTool();
    final context = ctx(controller);

    final handled = tool.onCellTap(context);

    expect(handled, isTrue);
    expect(controller.layout.placements, hasLength(1));
  });

  test('onPlacementTap selects placement and returns true', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final tool = DefaultTool();

    final handled = tool.onPlacementTap(ctx(controller), placement);

    expect(handled, isTrue);
    expect(controller.selectedPlacementId, placement.id);
  });

  test('onCellHover updates hover state', () {
    final controller = EditorController()..loadCatalog(catalog);
    final interactionState = GridInteractionState();
    controller.attachInteractionState(interactionState);
    final tool = DefaultTool();
    final context = GridToolContext(
      row: 2,
      col: 3,
      controller: controller,
      engine: controller.engine,
    );

    tool.onCellHover(context);

    expect(interactionState.hoverRow, 2);
    expect(interactionState.hoverCol, 3);
  });
}
