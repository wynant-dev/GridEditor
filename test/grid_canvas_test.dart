import 'package:flutter/material.dart';
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

  testWidgets('tapping a placement invokes onPlacementTap', (tester) async {
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

  testWidgets('ghost preview renders when item selected and cell hovered',
      (tester) async {
    final controller = EditorController()..loadCatalog(catalog);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => GridCanvas(
              document: const GridDocument(rows: 2, cols: 2),
              catalog: catalog,
              controller: controller,
            ),
          ),
        ),
      ),
    );

    expect(find.text('House'), findsNothing);

    controller.setHoverCell(0, 0);
    await tester.pump();

    expect(find.text('House'), findsOneWidget);
    expect(find.byType(Opacity), findsOneWidget);
  });

  testWidgets('ghost preview hidden when hover cleared', (tester) async {
    final controller = EditorController()..loadCatalog(catalog);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => GridCanvas(
              document: const GridDocument(rows: 2, cols: 2),
              catalog: catalog,
              controller: controller,
            ),
          ),
        ),
      ),
    );

    controller.setHoverCell(0, 0);
    await tester.pump();
    expect(find.text('House'), findsOneWidget);

    controller.setHoverCell(null, null);
    await tester.pump();
    expect(find.text('House'), findsNothing);
  });

  testWidgets('cell tap still places item when controller is attached',
      (tester) async {
    final controller = EditorController()..loadCatalog(catalog);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: GridCanvas(
            document: const GridDocument(rows: 2, cols: 2),
            catalog: catalog,
            controller: controller,
            onCellTap: controller.placeAt,
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(50, 50));
    expect(controller.layout.placements, hasLength(1));
  });
}
