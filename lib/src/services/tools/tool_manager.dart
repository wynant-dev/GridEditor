import 'package:flutter/foundation.dart';

import '../../domain/layout/placed_item.dart';
import 'default_tool.dart';
import 'editor_tool.dart';
import 'grid_tool_context.dart';
import 'place_tool.dart';

class ToolManager extends ChangeNotifier {
  ToolManager({
    EditorTool? activeTool,
    DefaultTool? defaultTool,
  }) : defaultTool = defaultTool ?? DefaultTool(),
       _activeTool = activeTool ?? PlaceTool();

  final DefaultTool defaultTool;
  EditorTool _activeTool;

  EditorTool get activeTool => _activeTool;

  void setTool(EditorTool tool) {
    _activeTool = tool;
    notifyListeners();
  }

  void handleCellHover(GridToolContext ctx) {
    _activeTool.onCellHover(ctx);
    defaultTool.onCellHover(ctx);
  }

  void handleCellTap(GridToolContext ctx) {
    if (!_activeTool.onCellTap(ctx)) {
      defaultTool.onCellTap(ctx);
    }
  }

  void handlePlacementTap(GridToolContext ctx, PlacedItem placement) {
    if (!_activeTool.onPlacementTap(ctx, placement)) {
      defaultTool.onPlacementTap(ctx, placement);
    }
  }
}
