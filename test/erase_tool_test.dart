import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 1, height: 1),
    ],
  );

  test('onPlacementTap removes placement and returns true', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final tool = EraseTool();
    final ctx = EditorToolContext(
      row: 0,
      col: 0,
      controller: controller,
      engine: controller.engine,
    );

    expect(tool.onPlacementTap(ctx, placement), isTrue);
    expect(controller.layout.placements, isEmpty);
  });

  test('onCellTap returns false', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    final tool = EraseTool();
    final ctx = EditorToolContext(
      row: 0,
      col: 0,
      controller: controller,
      engine: controller.engine,
    );

    expect(tool.onCellTap(ctx), isFalse);
    expect(controller.layout.placements, isEmpty);
  });
}
