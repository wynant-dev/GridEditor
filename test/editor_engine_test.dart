import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 2, height: 2),
      CatalogItem(id: 'bank', name: 'Bank', categoryId: 'buildings', width: 2, height: 1),
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

    test('placeItem assigns unique ids after deletion', () {
      var engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeItem(
        catalogItemId: 'house',
        originRow: 0,
        originCol: 0,
      );
      expect(engine.layout.placements.single.id, 'p1');

      engine = engine.placeItem(
        catalogItemId: 'bank',
        originRow: 2,
        originCol: 0,
      );
      expect(engine.layout.placements.last.id, 'p2');

      engine = engine.removePlacement('p1');
      engine = engine.placeItem(
        catalogItemId: 'bank',
        originRow: 0,
        originCol: 0,
      );

      final ids = engine.layout.placements.map((p) => p.id).toList();
      expect(ids, contains('p2'));
      expect(ids, contains('p3'));
      expect(ids.toSet(), hasLength(2));
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

    test('movePlacement updates placement origin while preserving id', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeItem(
        catalogItemId: 'house',
        originRow: 0,
        originCol: 0,
        placementId: 'p1',
      );

      final moved = engine.movePlacement(
        placementId: 'p1',
        newRow: 2,
        newCol: 2,
      );

      final placement = moved.layout.placements.single;
      expect(placement.id, 'p1');
      expect(placement.originRow, 2);
      expect(placement.originCol, 2);
    });

    test('movePlacement rejects overlapping placements', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(
          rows: 4,
          cols: 4,
          placements: [
            PlacedItem(
              id: 'p1',
              catalogItemId: 'house',
              originRow: 0,
              originCol: 0,
            ),
            PlacedItem(
              id: 'p2',
              catalogItemId: 'bank',
              originRow: 2,
              originCol: 0,
            ),
          ],
        ),
      );

      expect(
        () => engine.movePlacement(
          placementId: 'p1',
          newRow: 2,
          newCol: 0,
        ),
        throwsStateError,
      );
    });

    test('movePlacement rejects out-of-bounds target', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeItem(
        catalogItemId: 'house',
        originRow: 0,
        originCol: 0,
        placementId: 'p1',
      );

      expect(
        () => engine.movePlacement(
          placementId: 'p1',
          newRow: 3,
          newCol: 3,
        ),
        throwsStateError,
      );
    });

    test('movePlacement allows no-op move to same origin', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).placeItem(
        catalogItemId: 'house',
        originRow: 1,
        originCol: 1,
        placementId: 'p1',
      );

      final moved = engine.movePlacement(
        placementId: 'p1',
        newRow: 1,
        newCol: 1,
      );

      expect(moved.layout.placements.single.originRow, 1);
      expect(moved.layout.placements.single.originCol, 1);
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

  test('Catalog round-trips through JSON', () {
    const catalog = Catalog(
      id: 'ddv',
      name: 'DDV',
      items: [
        CatalogItem(
          id: 'house',
          name: 'House',
          categoryId: 'buildings',
          width: 4,
          height: 4,
          color: '#E53935',
        ),
      ],
    );

    final restored = Catalog.fromJson(catalog.toJson());
    expect(restored.name, 'DDV');
    expect(restored.items.single.width, 4);
  });
}
