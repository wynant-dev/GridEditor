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

    await tester.tapAt(const Offset(50, 50));
    expect(tapped, placement);
  });

  testWidgets('ghost preview renders when item selected and cell hovered',
      (tester) async {
    final controller = EditorController()..loadCatalog(catalog);
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
    final controller = EditorController()..loadCatalog(catalog);
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
    expect(find.byType(SelectionOverlayLayer), findsOneWidget);
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
    final controller = EditorController()..loadCatalog(catalog);

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
}
