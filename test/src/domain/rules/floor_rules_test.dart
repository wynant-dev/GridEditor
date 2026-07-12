import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    floors: [
      CatalogFloor(id: 'water', name: 'Water', color: '#42A5F5'),
    ],
  );

  const layout = GridDocument(rows: 4, cols: 4);

  group('FloorRules', () {
    test('accepts valid floor cell', () {
      expect(
        FloorRules.floorError(
          catalog: catalog,
          layout: layout,
          row: 1,
          col: 2,
          catalogFloorId: 'water',
        ),
        isNull,
      );
    });

    test('rejects unknown floor', () {
      expect(
        FloorRules.floorError(
          catalog: catalog,
          layout: layout,
          row: 0,
          col: 0,
          catalogFloorId: 'missing',
        ),
        'Unknown floor: missing',
      );
    });

    test('rejects out-of-bounds cell', () {
      expect(
        FloorRules.floorError(
          catalog: catalog,
          layout: layout,
          row: 4,
          col: 0,
          catalogFloorId: 'water',
        ),
        'Floor cell is out of bounds',
      );
    });
  });
}
