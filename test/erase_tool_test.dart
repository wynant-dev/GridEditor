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

  test('onPlacementTap removes placement from layout', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final tool = EraseTool();
    final ctx = GridToolContext(
      row: 0,
      col: 0,
      controller: controller,
      engine: controller.engine,
    );

    tool.onPlacementTap(ctx, placement);

    expect(controller.layout.placements, isEmpty);
  });
}
