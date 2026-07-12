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

  test('onItemTap removes item and returns true', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    controller.placeAt(0, 0);
    final item = controller.layout.items.single;
    final tool = EraseTool();
    final ctx = testToolContext(controller);

    expect(tool.onItemTap(ctx, item), isTrue);
    expect(controller.layout.items, isEmpty);
  });

  test('onCellTap returns false', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
    final tool = EraseTool();
    final ctx = testToolContext(controller);

    expect(tool.onCellTap(ctx), isFalse);
    expect(controller.layout.items, isEmpty);
  });
}
