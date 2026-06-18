import 'package:flutter/foundation.dart';

import '../../domain/layout/placed_item.dart';
import 'editor_tool.dart';
import 'erase_tool.dart';
import 'grid_tool_context.dart';

class ToolManager extends ChangeNotifier {
  ToolManager(this._tool, {EraseTool? eraseTool})
    : _eraseTool = eraseTool ?? EraseTool();

  EditorTool _tool;
  final EraseTool _eraseTool;

  EditorTool get tool => _tool;

  void setTool(EditorTool tool) {
    _tool = tool;
    notifyListeners();
  }

  void handleCellHover(GridToolContext ctx) {
    _tool.onCellHover(ctx);
  }

  void handleCellTap(GridToolContext ctx) {
    _tool.onCellTap(ctx);
  }

  void handlePlacementTap(GridToolContext ctx, PlacedItem placement) {
    _eraseTool.onPlacementTap(ctx, placement);
  }
}
