import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  testWidgets('tapping a placement invokes onPlacementTap', (tester) async {
    const catalog = ItemCatalog(
      id: 'test',
      name: 'Test',
      items: [
        CatalogItem(id: 'house', name: 'House', width: 1, height: 1),
      ],
    );
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    PlacedItem? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: GridCanvas(
            document: const GridDocument(
              rows: 2,
              cols: 2,
              placements: [placement],
            ),
            catalog: catalog,
            onPlacementTap: (p) => tapped = p,
          ),
        ),
      ),
    );

    await tester.tap(find.text('House'));
    expect(tapped, placement);
  });
}
