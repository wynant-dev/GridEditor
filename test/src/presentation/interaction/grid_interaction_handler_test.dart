import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';
import 'package:grid_editor/src/presentation/interaction/grid_interaction_handler.dart';

import '../../../helpers/grid_test_helpers.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 1, height: 1),
    ],
  );

  group('GridInteractionHandler drag', () {
    late EditorController editorController;
    late GridInteractionState interactionState;
    late GridInteractionHandler handler;
    late GridMetrics metrics;

    setUp(() {
      final document = const GridDocument(
        rows: 4,
        cols: 4,
        items: [
          Item(
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
      metrics = GridMetrics(
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
      handler.handlePointerDown(pointer.down(cellCenter(metrics, 0, 0)));
      handler.handlePointerMove(pointer.move(cellCenter(metrics, 0, 1)));
      handler.handlePointerUp(pointer.up());

      expect(editorController.layout.items.single.originCol, 1);
      expect(interactionState.isDragging, isFalse);
      expect(editorController.selectedItemId, 'p1');
    });

    test('drag to invalid cell reverts without mutating layout', () {
      const blockedDocument = GridDocument(
        rows: 4,
        cols: 4,
        items: [
          Item(
            id: 'p1',
            catalogItemId: 'house',
            originRow: 0,
            originCol: 0,
          ),
          Item(
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
      handler.updateContext(
        mapper: GridCoordinateMapper(metrics),
        document: blockedDocument,
        catalog: catalog,
        editorController: blocked,
        toolManager: blocked.toolManager,
      );

      final pointer = TestPointer(3);
      handler.handlePointerDown(pointer.down(cellCenter(metrics, 0, 0)));
      handler.handlePointerMove(pointer.move(cellCenter(metrics, 0, 1)));
      handler.handlePointerUp(pointer.up());

      expect(blocked.layout.itemById('p1')?.originCol, 0);
    });

    test('tap without slop selects item instead of moving', () {
      final pointer = TestPointer(2);
      final down = cellCenter(metrics, 0, 0);
      handler.handlePointerDown(pointer.down(down));
      handler.handlePointerMove(pointer.move(down + const Offset(2, 2)));
      handler.handlePointerUp(pointer.up());

      expect(editorController.layout.items.single.originCol, 0);
      expect(editorController.selectedItemId, 'p1');
    });

    test('drag preserves grab point when starting from footprint center', () {
      const largeCatalog = Catalog(
        id: 'test',
        name: 'Test',
        items: [
          CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 2, height: 2),
        ],
      );
      const document = GridDocument(
        rows: 4,
        cols: 4,
        items: [
          Item(
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
      handler.updateContext(
        mapper: GridCoordinateMapper(metrics),
        document: document,
        catalog: largeCatalog,
        editorController: largeController,
        toolManager: largeController.toolManager,
      );

      final pointer = TestPointer(4);
      final footprintCenter = cellCenter(metrics, 0, 0) + const Offset(24, 24);
      handler.handlePointerDown(pointer.down(footprintCenter));
      handler.handlePointerMove(pointer.move(footprintCenter + const Offset(30, 30)));
      handler.handlePointerUp(pointer.up());

      expect(largeController.layout.items.single.originRow, 0);
      expect(largeController.layout.items.single.originCol, 0);
    });
  });

  group('GridInteractionHandler sticker drag', () {
    const stickerCatalog = Catalog(
      id: 'test',
      name: 'Test',
      stickers: [
        CatalogSticker(
          id: 'tree',
          name: 'Tree',
          iconName: 'park',
        ),
      ],
    );

    test('drag commits sticker move', () {
      final metrics = GridMetrics(
        rows: 4,
        cols: 4,
        size: const Size(400, 400),
      );
      final center = cellCenter(metrics, 0, 0);
      final document = GridDocument(
        rows: 4,
        cols: 4,
        stickers: [
          Sticker(
            id: 's1',
            catalogStickerId: 'tree',
            x: center.dx,
            y: center.dy,
          ),
        ],
      );
      final editorController = EditorController(
        engine: EditorEngine(catalog: stickerCatalog, layout: document),
      )..loadCatalog(stickerCatalog);
      final interactionState = GridInteractionState();
      final handler = GridInteractionHandler(
        mapper: GridCoordinateMapper(metrics),
        document: document,
        catalog: stickerCatalog,
        interactionState: interactionState,
        editorController: editorController,
        toolManager: editorController.toolManager,
      );

      final pointer = TestPointer(5);
      final target = cellCenter(metrics, 1, 1);
      handler.handlePointerDown(pointer.down(center));
      handler.handlePointerMove(pointer.move(target));
      handler.handlePointerUp(pointer.up());

      final sticker = editorController.layout.stickers.single;
      expect(sticker.x, closeTo(target.dx, 0.01));
      expect(sticker.y, closeTo(target.dy, 0.01));
      expect(editorController.selectedStickerId, 's1');
    });
  });
}
