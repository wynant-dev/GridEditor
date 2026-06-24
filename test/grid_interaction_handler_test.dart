import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';
import 'package:grid_editor/src/presentation/interaction/grid_interaction_handler.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', width: 1, height: 1),
    ],
  );

  group('GridInteractionHandler drag', () {
    late EditorController editorController;
    late GridInteractionState interactionState;
    late GridInteractionHandler handler;

    setUp(() {
      final document = const GridDocument(
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
      editorController = EditorController(
        engine: EditorEngine(catalog: catalog, layout: document),
      )..loadCatalog(catalog);
      interactionState = GridInteractionState();
      final metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: const Size(400, 400),
      );
      handler = GridInteractionHandler(
        mapper: GridCoordinateMapper(metrics),
        document: document,
        catalog: catalog,
        interactionState: interactionState,
        editorController: editorController,
        toolManager: editorController.toolManager,
      );
    });

    test('drag beyond slop commits move to hovered cell', () {
      final pointer = TestPointer(1);
      handler.handlePointerDown(pointer.down(const Offset(50, 50)));
      handler.handlePointerMove(pointer.move(const Offset(170, 50)));
      handler.handlePointerUp(pointer.up());

      expect(editorController.layout.placements.single.originCol, 1);
      expect(interactionState.isDragging, isFalse);
      expect(editorController.selectedPlacementId, 'p1');
    });

    test('drag to invalid cell reverts without mutating layout', () {
      const blockedDocument = GridDocument(
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
            catalogItemId: 'house',
            originRow: 0,
            originCol: 1,
          ),
        ],
      );
      final blocked = EditorController(
        engine: EditorEngine(catalog: catalog, layout: blockedDocument),
      )..loadCatalog(catalog);
      final metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: const Size(400, 400),
      );
      handler.updateContext(
        mapper: GridCoordinateMapper(metrics),
        document: blockedDocument,
        catalog: catalog,
        editorController: blocked,
        toolManager: blocked.toolManager,
      );

      final pointer = TestPointer(3);
      handler.handlePointerDown(pointer.down(const Offset(50, 50)));
      handler.handlePointerMove(pointer.move(const Offset(170, 50)));
      handler.handlePointerUp(pointer.up());

      expect(blocked.layout.placementById('p1')?.originCol, 0);
    });

    test('tap without slop selects placement instead of moving', () {
      final pointer = TestPointer(2);
      handler.handlePointerDown(pointer.down(const Offset(50, 50)));
      handler.handlePointerMove(pointer.move(const Offset(52, 52)));
      handler.handlePointerUp(pointer.up());

      expect(editorController.layout.placements.single.originCol, 0);
      expect(editorController.selectedPlacementId, 'p1');
    });

    test('drag preserves grab point when starting from footprint center', () {
      const largeCatalog = Catalog(
        id: 'test',
        name: 'Test',
        items: [
          CatalogItem(id: 'house', name: 'House', width: 2, height: 2),
        ],
      );
      const document = GridDocument(
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
      final largeController = EditorController(
        engine: EditorEngine(catalog: largeCatalog, layout: document),
      )..loadCatalog(largeCatalog);
      final metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: const Size(400, 400),
      );
      handler.updateContext(
        mapper: GridCoordinateMapper(metrics),
        document: document,
        catalog: largeCatalog,
        editorController: largeController,
        toolManager: largeController.toolManager,
      );

      final pointer = TestPointer(4);
      handler.handlePointerDown(pointer.down(const Offset(150, 150)));
      handler.handlePointerMove(pointer.move(const Offset(180, 180)));
      handler.handlePointerUp(pointer.up());

      expect(largeController.layout.placements.single.originRow, 0);
      expect(largeController.layout.placements.single.originCol, 0);
    });
  });
}
