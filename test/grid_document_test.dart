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

  test('placementById returns matching placement', () {
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    const document = GridDocument(
      rows: 2,
      cols: 2,
      placements: [placement],
    );

    expect(document.placementById('p1'), placement);
    expect(document.placementById('missing'), isNull);
  });

  test('EditorEngine placementById delegates to layout', () {
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    final engine = EditorEngine(
      catalog: catalog,
      layout: const GridDocument(
        rows: 2,
        cols: 2,
        placements: [placement],
      ),
    );

    expect(engine.placementById('p1'), placement);
  });
}
