import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = ItemCatalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', width: 2, height: 2),
      CatalogItem(id: 'bank', name: 'Bank', width: 2, height: 1),
    ],
  );

  group('PlacementRules', () {
    test('rejects unknown catalog item', () {
      const layout = GridDocument(rows: 4, cols: 4);
      expect(
        PlacementRules.placementError(
          catalog: catalog,
          layout: layout,
          catalogItemId: 'missing',
          originRow: 0,
          originCol: 0,
        ),
        'Unknown item: missing',
      );
    });

    test('rejects overlapping footprints', () {
      const layout = GridDocument(
        rows: 4,
        cols: 4,
        placements: [
          PlacedItem(
            id: 'p1',
            catalogItemId: 'house',
            originRow: 0,
            originCol: 0,
          ),
        ],
      );

      expect(
        PlacementRules.placementError(
          catalog: catalog,
          layout: layout,
          catalogItemId: 'bank',
          originRow: 0,
          originCol: 1,
        ),
        'Item overlaps another placement',
      );
    });
  });

  group('EditorEngine', () {
    test('placeItem stores a footprint on the layout', () {
      const layout = GridDocument(rows: 4, cols: 4);
      final engine = const EditorEngine(catalog: catalog, layout: layout)
          .placeItem(
            catalogItemId: 'house',
            originRow: 0,
            originCol: 0,
            placementId: 'p1',
          );

      expect(engine.layout.placements, hasLength(1));
      expect(engine.occupiesCell(row: 1, col: 1), isTrue);
    });

    test('placeItem rejects overlapping placements', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeItem(
        catalogItemId: 'house',
        originRow: 0,
        originCol: 0,
      );

      expect(
        () => engine.placeItem(
          catalogItemId: 'bank',
          originRow: 0,
          originCol: 1,
        ),
        throwsStateError,
      );
    });

    test('layout round-trips through JSON', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 3, cols: 3),
      ).placeItem(
        catalogItemId: 'bank',
        originRow: 1,
        originCol: 1,
        placementId: 'p1',
      );

      final restored = EditorEngine.fromLayoutJson(
        catalog: catalog,
        source: engine.layoutToJson(),
      );
      expect(restored.layout.placements.single.catalogItemId, 'bank');
    });
  });

  test('ItemCatalog round-trips through JSON', () {
    const catalog = ItemCatalog(
      id: 'ddv',
      name: 'DDV',
      items: [
        CatalogItem(
          id: 'house',
          name: 'House',
          width: 4,
          height: 4,
          color: '#E53935',
        ),
      ],
    );

    final restored = ItemCatalog.fromJson(catalog.toJson());
    expect(restored.name, 'DDV');
    expect(restored.items.single.width, 4);
  });
}
