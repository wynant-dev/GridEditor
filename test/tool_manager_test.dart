import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

class _RecordingTool implements EditorTool {
  int hoverCount = 0;
  int tapCount = 0;

  @override
  void onCellHover(GridToolContext ctx) => hoverCount++;

  @override
  void onCellTap(GridToolContext ctx) => tapCount++;
}

class _RecordingEraseTool extends EraseTool {
  PlacedItem? removed;

  @override
  void onPlacementTap(GridToolContext ctx, PlacedItem placement) {
    removed = placement;
    super.onPlacementTap(ctx, placement);
  }
}

void main() {
  const catalog = ItemCatalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', width: 1, height: 1),
    ],
  );

  GridToolContext ctx(EditorController controller) => GridToolContext(
    row: 0,
    col: 0,
    controller: controller,
    engine: controller.engine,
  );

  test('handleCellHover delegates to active tool', () {
    final controller = EditorController()..loadCatalog(catalog);
    final tool = _RecordingTool();
    final manager = ToolManager(tool);

    manager.handleCellHover(ctx(controller));

    expect(tool.hoverCount, 1);
  });

  test('handleCellTap delegates to active tool', () {
    final controller = EditorController()..loadCatalog(catalog);
    final tool = _RecordingTool();
    final manager = ToolManager(tool);

    manager.handleCellTap(ctx(controller));

    expect(tool.tapCount, 1);
  });

  test('handlePlacementTap delegates to erase tool', () {
    final controller = EditorController()..loadCatalog(catalog);
    controller.placeAt(0, 0);
    final placement = controller.layout.placements.single;
    final eraseTool = _RecordingEraseTool();
    final manager = ToolManager(_RecordingTool(), eraseTool: eraseTool);

    manager.handlePlacementTap(ctx(controller), placement);

    expect(eraseTool.removed, placement);
    expect(controller.layout.placements, isEmpty);
  });

  test('setTool updates active tool and notifies listeners', () {
    final controller = EditorController()..loadCatalog(catalog);
    final first = _RecordingTool();
    final second = _RecordingTool();
    final manager = ToolManager(first);
    var notified = 0;
    manager.addListener(() => notified++);

    manager.setTool(second);
    manager.handleCellTap(ctx(controller));

    expect(first.tapCount, 0);
    expect(second.tapCount, 1);
    expect(notified, 1);
  });
}
