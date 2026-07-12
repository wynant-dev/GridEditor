import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

import '../../../helpers/grid_test_helpers.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 1, height: 1),
    ],
  );

  testWidgets('tapping an item invokes onItemTap', (tester) async {
    setGridTestViewSize(tester);
    const item = Item(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    Item? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: GridCanvas(
            document: const GridDocument(
              rows: 2,
              cols: 2,
              items: [item],
            ),
            catalog: catalog,
            onItemTap: (p) => tapped = p,
          ),
        ),
      ),
    );

    await tapGridCell(
      tester,
      metrics: testMetrics(rows: 2, cols: 2),
      row: 0,
      col: 0,
    );
    expect(tapped, item);
  });

  testWidgets('item preview renders at full opacity when hover is valid',
      (tester) async {
    setGridTestViewSize(tester);
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
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
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('item preview is ghosted when hover is invalid',
      (tester) async {
    setGridTestViewSize(tester);
    const item = Item(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
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
              items: [item],
            ),
            catalog: catalog,
            controller: controller,
            interactionState: interactionState,
          ),
        ),
      ),
    );

    interactionState.setHoverCell(0, 0);
    await tester.pump();

    expect(find.text('House'), findsWidgets);
    expect(find.byType(Opacity), findsOneWidget);
  });

  testWidgets('ghost preview hidden when hover cleared', (tester) async {
    setGridTestViewSize(tester);
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
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
    setGridTestViewSize(tester);
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');

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

    await tapGridCell(
      tester,
      metrics: testMetrics(rows: 2, cols: 2),
      row: 0,
      col: 0,
    );
    expect(controller.layout.items, hasLength(1));
  });

  testWidgets('tapping an item selects it when controller is attached',
      (tester) async {
    setGridTestViewSize(tester);
    const item = Item(
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
              items: [item],
            ),
            catalog: catalog,
            controller: controller,
          ),
        ),
      ),
    );

    await tapGridCell(
      tester,
      metrics: testMetrics(rows: 2, cols: 2),
      row: 0,
      col: 0,
    );
    expect(controller.selectedItemId, 'p1');
    expect(controller.selectedCatalogItemId, isNull);
    expect(find.byType(SelectionOverlayLayer), findsOneWidget);
  });

  testWidgets('ghost preview hidden when item is selected', (tester) async {
    setGridTestViewSize(tester);
    const item = Item(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');
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
              items: [item],
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
    expect(find.byType(Opacity), findsNothing);

    await tapGridCell(
      tester,
      metrics: testMetrics(rows: 2, cols: 2),
      row: 0,
      col: 0,
    );
    await tester.pump();

    expect(controller.selectedItemId, 'p1');
    expect(controller.selectedCatalogItemId, isNull);
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('delete button removes selected item', (tester) async {
    setGridTestViewSize(tester);
    const item = Item(
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
          items: [item],
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

    await tapGridCell(
      tester,
      metrics: testMetrics(rows: 2, cols: 2),
      row: 0,
      col: 0,
    );
    await tester.pump();
    expect(controller.selectedItemId, 'p1');

    await tester.tap(find.byKey(const Key('delete_item_button')));
    await tester.pump();

    expect(controller.layout.items, isEmpty);
    expect(controller.selectedCatalogItemId, isNull);
  });

  testWidgets('EraseTool active removes item on tap', (tester) async {
    setGridTestViewSize(tester);
    const item = Item(
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
          items: [item],
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
              items: [item],
            ),
            catalog: catalog,
            controller: controller,
          ),
        ),
      ),
    );

    await tapGridCell(
      tester,
      metrics: testMetrics(rows: 2, cols: 2),
      row: 0,
      col: 0,
    );
    expect(controller.layout.items, isEmpty);
  });

  testWidgets('64x64 grid uses no per-cell GestureDetectors', (tester) async {
    setGridTestViewSize(tester, size: const Size(640, 640));
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectCatalogItem('house');

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

    await tapGridCell(
      tester,
      metrics: testMetrics(rows: 64, cols: 64, size: const Size(640, 640)),
      row: 32,
      col: 32,
    );
    expect(controller.layout.items, hasLength(1));
  });

  testWidgets('dragging to invalid cell reverts item', (tester) async {
    setGridTestViewSize(tester, size: const Size(400, 400));
    const item = Item(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    const blocker = Item(
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
          items: [item, blocker],
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

    final metrics = testMetrics(rows: 4, cols: 4, size: const Size(400, 400));
    await dragBetweenCells(
      tester,
      metrics: metrics,
      fromRow: 0,
      fromCol: 0,
      toRow: 0,
      toCol: 1,
    );
    await tester.pump();

    final moved = controller.layout.itemById('p1');
    expect(moved?.originRow, 0);
    expect(moved?.originCol, 0);
  });
}
