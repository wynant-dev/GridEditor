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
  );

  test('onCellTap places item and returns true', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    final tool = PlaceTool();
    final ctx = testToolContext(controller);

    expect(tool.onCellTap(ctx), isTrue);
    expect(controller.layout.placements, hasLength(1));
  });

  test('onPlacementTap returns false', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final tool = PlaceTool();
    final ctx = testToolContext(controller);

    expect(tool.onPlacementTap(ctx, placement), isFalse);
    expect(controller.selectedPlacementId, isNull);
  });

  test('onCellHover delegates to onHover callback', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
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

  test('onCellTap reports placement error via callback', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);
    String? reportedError;
    final tool = PlaceTool(onPlaceError: (error) => reportedError = error);
    final ctx = testToolContext(controller);

    tool.onCellTap(ctx);

    expect(reportedError, isNotNull);
    expect(controller.layout.placements, hasLength(1));
  });
}
