import 'package:flutter/material.dart';
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

    await tester.tapAt(const Offset(50, 50));
    expect(tapped, placement);
  });

  testWidgets('ghost preview renders when item selected and cell hovered',
      (tester) async {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    final interactionState = GridInteractionState();

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: GridCanvas(
            document: const GridDocument(rows: 2, cols: 2),
            catalog: catalog,
            controller: controller,
            interactionState: interactionState,
          ),
        ),
      ),
    );

    expect(find.text('House'), findsNothing);

    interactionState.setHoverCell(0, 0);
    await tester.pump();

    expect(find.text('House'), findsOneWidget);
    expect(find.byType(Opacity), findsOneWidget);
  });

  testWidgets('ghost preview hidden when hover cleared', (tester) async {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    final interactionState = GridInteractionState();

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: GridCanvas(
            document: const GridDocument(rows: 2, cols: 2),
            catalog: catalog,
            controller: controller,
            interactionState: interactionState,
          ),
        ),
      ),
    );

    interactionState.setHoverCell(0, 0);
    await tester.pump();
    expect(find.text('House'), findsOneWidget);

    interactionState.setHoverCell(null, null);
    await tester.pump();
    expect(find.text('House'), findsNothing);
  });

  testWidgets('cell tap still places item when controller is attached',
      (tester) async {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: GridCanvas(
            document: const GridDocument(rows: 2, cols: 2),
            catalog: catalog,
            controller: controller,
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(50, 50));
    expect(controller.layout.placements, hasLength(1));
  });

  testWidgets('tapping a placement selects it when controller is attached',
      (tester) async {
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    final controller = EditorController()..loadCatalog(catalog);

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
            controller: controller,
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(50, 50));
    expect(controller.selectedPlacementId, 'p1');
    expect(controller.selectedItemId, isNull);
    expect(find.byType(SelectionOverlayLayer), findsOneWidget);
  });

  testWidgets('ghost preview hidden when placement is selected', (tester) async {
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    final interactionState = GridInteractionState();

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
            controller: controller,
            interactionState: interactionState,
          ),
        ),
      ),
    );

    interactionState.setHoverCell(1, 1);
    await tester.pump();
    expect(find.byType(Opacity), findsOneWidget);

    await tester.tapAt(const Offset(50, 50));
    await tester.pump();

    expect(controller.selectedPlacementId, 'p1');
    expect(controller.selectedItemId, isNull);
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('delete button removes selected placement', (tester) async {
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    final controller = EditorController(
      engine: EditorEngine(
        catalog: catalog,
        layout: const GridDocument(
          rows: 2,
          cols: 2,
          placements: [placement],
        ),
      ),
    )..loadCatalog(catalog);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: GridCanvas(
            document: controller.layout,
            catalog: catalog,
            controller: controller,
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(50, 50));
    await tester.pump();
    expect(controller.selectedPlacementId, 'p1');

    await tester.tap(find.byKey(const Key('delete_placement_button')));
    await tester.pump();

    expect(controller.layout.placements, isEmpty);
    expect(controller.selectedPlacementId, isNull);
  });

  testWidgets('EraseTool active removes placement on tap', (tester) async {
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    final controller = EditorController(
      engine: EditorEngine(
        catalog: catalog,
        layout: const GridDocument(
          rows: 2,
          cols: 2,
          placements: [placement],
        ),
      ),
    )..loadCatalog(catalog);
    controller.toolManager.setTool(EraseTool());

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
            controller: controller,
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(50, 50));
    expect(controller.layout.placements, isEmpty);
  });

  testWidgets('64x64 grid uses no per-cell GestureDetectors', (tester) async {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 640,
          height: 640,
          child: GridCanvas(
            document: const GridDocument(rows: 64, cols: 64),
            catalog: catalog,
            controller: controller,
          ),
        ),
      ),
    );

    expect(find.byType(GestureDetector), findsNothing);
    expect(find.byType(GridInteractionLayer), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    expect(controller.layout.placements, hasLength(1));
  });

  testWidgets('dragging to invalid cell reverts placement', (tester) async {
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    const blocker = PlacedItem(
      id: 'p2',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 1,
    );
    final controller = EditorController(
      engine: EditorEngine(
        catalog: catalog,
        layout: const GridDocument(
          rows: 4,
          cols: 4,
          placements: [placement, blocker],
        ),
      ),
    )..loadCatalog(catalog);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 400,
          height: 400,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => GridCanvas(
              document: controller.layout,
              catalog: catalog,
              controller: controller,
            ),
          ),
        ),
      ),
    );

    final layerTopLeft = tester.getTopLeft(find.byType(GridInteractionLayer));
    await tester.dragFrom(layerTopLeft + const Offset(50, 50), const Offset(120, 0));
    await tester.pump();

    final moved = controller.layout.placementById('p1');
    expect(moved?.originRow, 0);
    expect(moved?.originCol, 0);
  });
}
