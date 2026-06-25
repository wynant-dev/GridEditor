import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', width: 1, height: 1),
    ],
    floors: [
      CatalogFloor(id: 'water', name: 'Water', color: '#42A5F5'),
    ],
  );

  test('onCellTap paints floor and returns true', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectFloor('water');
    final tool = FloorTool();
    final ctx = EditorToolContext(
      row: 2,
      col: 3,
      controller: controller,
      engine: controller.engine,
    );

    expect(tool.onCellTap(ctx), isTrue);
    expect(controller.layout.floorTiles, hasLength(1));
    expect(controller.layout.floorIdAt(2, 3), 'water');
  });

  test('onPlacementTap paints floor under item', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectItem('house');
    controller.placeAt(1, 1);
    controller.selectFloor('water');
    final placement = controller.layout.placements.single;
    final tool = FloorTool();
    final ctx = EditorToolContext(
      row: 1,
      col: 1,
      controller: controller,
      engine: controller.engine,
    );

    expect(tool.onPlacementTap(ctx, placement), isTrue);
    expect(controller.layout.floorIdAt(1, 1), 'water');
    expect(controller.layout.placements, hasLength(1));
  });

  test('canStartDrag returns false', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectItem('house');
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final tool = FloorTool();

    expect(tool.canStartDrag(placement), isFalse);
  });

  test('onCellHover delegates to onHover callback', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectFloor('water');
    final interactionState = GridInteractionState();
    final tool = FloorTool();
    final ctx = EditorToolContext(
      row: 4,
      col: 5,
      controller: controller,
      engine: controller.engine,
      onHover: (row, col) => interactionState.setHoverCell(row, col),
    );

    tool.onCellHover(ctx);

    expect(interactionState.hoverRow, 4);
    expect(interactionState.hoverCol, 5);
  });

  test('onCellHover paints while pointer is down', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectFloor('water');
    final tool = FloorTool();

    tool.onCellHover(
      EditorToolContext(
        row: 1,
        col: 1,
        controller: controller,
        engine: controller.engine,
        isPointerDown: true,
      ),
    );

    expect(controller.layout.floorIdAt(1, 1), 'water');
  });

  test('onCellHover stroke skips duplicate cells', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectFloor('water');
    final tool = FloorTool();
    final ctx = EditorToolContext(
      row: 2,
      col: 2,
      controller: controller,
      engine: controller.engine,
      isPointerDown: true,
    );

    tool.onCellHover(ctx);
    tool.onCellHover(ctx);

    expect(controller.layout.floorTiles, hasLength(1));
  });

  test('onCellHover stroke paints each new cell', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectFloor('water');
    final tool = FloorTool();

    tool.onCellHover(
      EditorToolContext(
        row: 0,
        col: 0,
        controller: controller,
        engine: controller.engine,
        isPointerDown: true,
      ),
    );
    tool.onCellHover(
      EditorToolContext(
        row: 0,
        col: 1,
        controller: controller,
        engine: controller.engine,
        isPointerDown: true,
      ),
    );

    expect(controller.layout.floorIdAt(0, 0), 'water');
    expect(controller.layout.floorIdAt(0, 1), 'water');
  });

  test('onPointerUp resets stroke so same cell can be painted again', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.selectFloor('water');
    final tool = FloorTool();
    final ctx = EditorToolContext(
      row: 3,
      col: 3,
      controller: controller,
      engine: controller.engine,
      isPointerDown: true,
    );

    tool.onCellHover(ctx);
    tool.onPointerUp();
    tool.onCellHover(ctx);

    expect(controller.layout.floorIdAt(3, 3), 'water');
  });
}
