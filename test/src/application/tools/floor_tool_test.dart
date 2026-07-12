import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

import '../../../helpers/grid_test_helpers.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 1, height: 1),
    ],
    floors: [
      CatalogFloor(id: 'water', name: 'Water', color: '#42A5F5'),
    ],
  );

  test('onCellTap paints floor and returns true', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectCatalogFloor('water');
    final tool = FloorTool();
    final ctx = testToolContext(controller, row: 2, col: 3);

    expect(tool.onCellTap(ctx), isTrue);
    expect(controller.layout.floors, hasLength(1));
    expect(controller.layout.floorIdAt(2, 3), 'water');
  });

  test('onItemTap paints floor under item', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectCatalogItem('house');
    controller.placeAt(1, 1);
    controller.selectCatalogFloor('water');
    final item = controller.layout.items.single;
    final tool = FloorTool();
    final ctx = testToolContext(controller, row: 1, col: 1);

    expect(tool.onItemTap(ctx, item), isTrue);
    expect(controller.layout.floorIdAt(1, 1), 'water');
    expect(controller.layout.items, hasLength(1));
  });

  test('canStartDrag returns false', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectCatalogItem('house');
    controller.placeAt(0, 0);
    final item = controller.layout.items.single;
    final tool = FloorTool();

    expect(tool.canStartDrag(item), isFalse);
  });

  test('onCellHover delegates to onHover callback', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectCatalogFloor('water');
    final interactionState = GridInteractionState();
    final tool = FloorTool();
    final ctx = testToolContext(
      controller,
      row: 4,
      col: 5,
      onHover: (row, col) => interactionState.setHoverCell(row, col),
    );

    tool.onCellHover(ctx);

    expect(interactionState.hoverRow, 4);
    expect(interactionState.hoverCol, 5);
  });

  test('onCellHover paints while pointer is down', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectCatalogFloor('water');
    final tool = FloorTool();

    tool.onCellHover(
      testToolContext(controller, row: 1, col: 1, isPointerDown: true),
    );

    expect(controller.layout.floorIdAt(1, 1), 'water');
  });

  test('onCellHover stroke skips duplicate cells', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectCatalogFloor('water');
    final tool = FloorTool();
    final ctx = testToolContext(
      controller,
      row: 2,
      col: 2,
      isPointerDown: true,
    );

    tool.onCellHover(ctx);
    tool.onCellHover(ctx);

    expect(controller.layout.floors, hasLength(1));
  });

  test('onCellHover stroke paints each new cell', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectCatalogFloor('water');
    final tool = FloorTool();

    tool.onCellHover(
      testToolContext(controller, row: 0, col: 0, isPointerDown: true),
    );
    tool.onCellHover(
      testToolContext(controller, row: 0, col: 1, isPointerDown: true),
    );

    expect(controller.layout.floorIdAt(0, 0), 'water');
    expect(controller.layout.floorIdAt(0, 1), 'water');
  });

  test('onPointerUp resets stroke so same cell can be painted again', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectCatalogFloor('water');
    final tool = FloorTool();
    final ctx = testToolContext(
      controller,
      row: 3,
      col: 3,
      isPointerDown: true,
    );

    tool.onCellHover(ctx);
    tool.onPointerUp();
    tool.onCellHover(ctx);

    expect(controller.layout.floorIdAt(3, 3), 'water');
  });
}
