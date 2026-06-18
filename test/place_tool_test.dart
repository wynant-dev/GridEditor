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

  test('onCellTap places item and returns true', () {
    final controller = EditorController()..loadCatalog(catalog);
    final tool = PlaceTool();
    final ctx = GridToolContext(
      row: 0,
      col: 0,
      controller: controller,
      engine: controller.engine,
    );

    expect(tool.onCellTap(ctx), isTrue);
    expect(controller.layout.placements, hasLength(1));
  });

  test('onPlacementTap returns false', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final tool = PlaceTool();
    final ctx = GridToolContext(
      row: 0,
      col: 0,
      controller: controller,
      engine: controller.engine,
    );

    expect(tool.onPlacementTap(ctx, placement), isFalse);
    expect(controller.selectedPlacementId, isNull);
  });

  test('onCellHover delegates to controller setHoverCell', () {
    final controller = EditorController()..loadCatalog(catalog);
    final interactionState = GridInteractionState();
    controller.attachInteractionState(interactionState);
    final tool = PlaceTool();
    final ctx = GridToolContext(
      row: 2,
      col: 3,
      controller: controller,
      engine: controller.engine,
    );

    tool.onCellHover(ctx);

    expect(interactionState.hoverRow, 2);
    expect(interactionState.hoverCol, 3);
  });

  test('onCellTap reports placement error via callback', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.placeAt(0, 0);
    String? reportedError;
    final tool = PlaceTool(onPlaceError: (error) => reportedError = error);
    final ctx = GridToolContext(
      row: 0,
      col: 0,
      controller: controller,
      engine: controller.engine,
    );

    tool.onCellTap(ctx);

    expect(reportedError, isNotNull);
    expect(controller.layout.placements, hasLength(1));
  });
}
