import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    floors: [
      CatalogFloor(id: 'water', name: 'Water', color: '#42A5F5'),
      CatalogFloor(id: 'grass', name: 'Grass', color: '#66BB6A'),
    ],
  );

  test('floorIdAt returns floor at cell', () {
    const document = GridDocument(
      rows: 4,
      cols: 4,
      floorTiles: [
        FloorTile(row: 1, col: 2, catalogFloorId: 'water'),
      ],
    );

    expect(document.floorIdAt(1, 2), 'water');
    expect(document.floorIdAt(0, 0), isNull);
  });

  test('floorIdAt falls back to defaultFloorId', () {
    const document = GridDocument(
      rows: 4,
      cols: 4,
      defaultFloorId: 'grass',
      floorTiles: [
        FloorTile(row: 1, col: 2, catalogFloorId: 'water'),
      ],
    );

    expect(document.floorIdAt(0, 0), 'grass');
    expect(document.floorIdAt(1, 2), 'water');
  });

  test('defaultFloorId round-trips through JSON', () {
    const document = GridDocument(
      rows: 3,
      cols: 3,
      defaultFloorId: 'grass',
      floorTiles: [
        FloorTile(row: 0, col: 1, catalogFloorId: 'water'),
      ],
    );

    final restored = GridDocument.fromJsonMap(document.toJsonMap());

    expect(restored.defaultFloorId, 'grass');
    expect(restored.floorIdAt(2, 2), 'grass');
    expect(restored.floorIdAt(0, 1), 'water');
  });

  test('floor tiles round-trip through JSON', () {
    const document = GridDocument(
      rows: 3,
      cols: 3,
      floorTiles: [
        FloorTile(row: 0, col: 1, catalogFloorId: 'grass'),
        FloorTile(row: 2, col: 0, catalogFloorId: 'water'),
      ],
    );

    final restored = GridDocument.fromJsonMap(document.toJsonMap());

    expect(restored.floorTiles, hasLength(2));
    expect(restored.floorIdAt(0, 1), 'grass');
    expect(restored.floorIdAt(2, 0), 'water');
  });

  group('EditorEngine applyFloor', () {
    test('stores floor tile on layout', () {
      const engine = EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      );

      final updated = engine.applyFloor(
        row: 1,
        col: 2,
        catalogFloorId: 'water',
      );

      expect(updated.layout.floorTiles, hasLength(1));
      expect(updated.floorIdAt(1, 2), 'water');
    });

    test('replaces existing floor at same cell', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      ).applyFloor(row: 1, col: 2, catalogFloorId: 'water');

      final updated = engine.applyFloor(
        row: 1,
        col: 2,
        catalogFloorId: 'grass',
      );

      expect(updated.layout.floorTiles, hasLength(1));
      expect(updated.floorIdAt(1, 2), 'grass');
    });

    test('painting default floor removes override tile', () {
      final engine = const EditorEngine(
        catalog: catalog,
        layout: GridDocument(
          rows: 4,
          cols: 4,
          defaultFloorId: 'grass',
        ),
      ).applyFloor(row: 1, col: 2, catalogFloorId: 'water');

      final updated = engine.applyFloor(
        row: 1,
        col: 2,
        catalogFloorId: 'grass',
      );

      expect(updated.layout.floorTiles, isEmpty);
      expect(updated.floorIdAt(1, 2), 'grass');
    });

    test('rejects unknown floor', () {
      const engine = EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      );

      expect(
        () => engine.applyFloor(row: 0, col: 0, catalogFloorId: 'missing'),
        throwsStateError,
      );
    });

    test('rejects out-of-bounds cell', () {
      const engine = EditorEngine(
        catalog: catalog,
        layout: GridDocument(rows: 4, cols: 4),
      );

      expect(
        () => engine.applyFloor(row: 4, col: 0, catalogFloorId: 'water'),
        throwsStateError,
      );
    });
  });

  test('Catalog floors round-trip through JSON', () {
    const catalog = Catalog(
      id: 'sandbox',
      name: 'Sandbox',
      floors: [
        CatalogFloor(id: 'water', name: 'Water', color: '#42A5F5'),
        CatalogFloor(id: 'sand', name: 'Sand', color: '#FFD54F'),
      ],
    );

    final restored = Catalog.fromJson(catalog.toJson());

    expect(restored.floors, hasLength(2));
    expect(restored.floorById('sand')?.name, 'Sand');
  });
}
