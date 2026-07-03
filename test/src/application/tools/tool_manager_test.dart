import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

import '../../../helpers/grid_test_helpers.dart';

class _RecordingTool extends EditorTool {
  int hoverCount = 0;
  int tapCount = 0;
  bool placementHandled = false;

  @override
  void onCellHover(EditorToolContext ctx) => hoverCount++;

  @override
  bool onCellTap(EditorToolContext ctx) {
    tapCount++;
    return true;
  }

  @override
  bool onPlacementTap(EditorToolContext ctx, PlacedItem placement) {
    placementHandled = true;
    return false;
  }
}

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 1, height: 1),
    ],
  );

  EditorToolContext ctx(EditorController controller) =>
      testToolContext(controller);

  test('handleCellHover calls active tool and default tool', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    final tool = _RecordingTool();
    final manager = ToolManager(activeTool: tool);

    manager.handleCellHover(ctx(controller));

    expect(tool.hoverCount, 1);
  });

  test('handleCellTap uses active tool when handled', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    final tool = _RecordingTool();
    final manager = ToolManager(activeTool: tool);

    manager.handleCellTap(ctx(controller));

    expect(tool.tapCount, 1);
  });

  test('handlePlacementTap falls back to DefaultTool when active does not handle',
      () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final tool = _RecordingTool();
    final manager = ToolManager(activeTool: tool);

    manager.handlePlacementTap(ctx(controller), placement);

    expect(tool.placementHandled, isTrue);
    expect(controller.selectedPlacementId, placement.id);
    expect(controller.layout.placements, hasLength(1));
  });

  test('handlePlacementTap erases when EraseTool is active', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final manager = ToolManager(activeTool: EraseTool());

    manager.handlePlacementTap(ctx(controller), placement);

    expect(controller.layout.placements, isEmpty);
  });

  test('setTool updates active tool and notifies listeners', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    final first = _RecordingTool();
    final second = _RecordingTool();
    final manager = ToolManager(activeTool: first);
    var notified = 0;
    manager.addListener(() => notified++);

    manager.setTool(second);
    manager.handleCellTap(ctx(controller));

    expect(first.tapCount, 0);
    expect(second.tapCount, 1);
    expect(notified, 1);
  });

  test('handlePlacementTap ignores taps while dragging', () {
    final controller = EditorController()
      ..loadCatalog(catalog)
      ..selectItem('house');
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final manager = ToolManager(activeTool: EraseTool());

    manager.handlePlacementTap(
      ctx(controller),
      placement,
      isDragging: true,
    );

    expect(controller.layout.placements, hasLength(1));
  });
}
