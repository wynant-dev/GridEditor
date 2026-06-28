import 'package:flutter/foundation.dart';

import '../../domain/layout/placed_item.dart';
import '../../domain/layout/placed_sticker.dart';
import 'default_tool.dart';
import 'editor_tool.dart';
import 'editor_tool_context.dart';
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

  void handleCellHover(EditorToolContext ctx) {
    _activeTool.onCellHover(ctx);
    defaultTool.onCellHover(ctx);
  }

  void handlePointerUp() {
    _activeTool.onPointerUp();
    defaultTool.onPointerUp();
  }

  void handleCellTap(EditorToolContext ctx, {bool isDragging = false}) {
    if (isDragging) return;
    if (!_activeTool.onCellTap(ctx)) {
      defaultTool.onCellTap(ctx);
    }
  }

  bool handleWorldTap(EditorToolContext ctx, {bool isDragging = false}) {
    if (isDragging) return false;
    if (_activeTool.onWorldTap(ctx)) return true;
    return defaultTool.onWorldTap(ctx);
  }

  void handlePlacementTap(
    EditorToolContext ctx,
    PlacedItem placement, {
    bool isDragging = false,
  }) {
    if (isDragging) return;
    if (!_activeTool.onPlacementTap(ctx, placement)) {
      defaultTool.onPlacementTap(ctx, placement);
    }
  }

  void handleStickerTap(
    EditorToolContext ctx,
    PlacedSticker sticker, {
    bool isDragging = false,
  }) {
    if (isDragging) return;
    if (!_activeTool.onStickerTap(ctx, sticker)) {
      defaultTool.onStickerTap(ctx, sticker);
    }
  }

  bool canStartDrag(PlacedItem placement) {
    return _activeTool.canStartDrag(placement) &&
        defaultTool.canStartDrag(placement);
  }

  bool canStartStickerDrag(PlacedSticker sticker) {
    return _activeTool.canStartStickerDrag(sticker) &&
        defaultTool.canStartStickerDrag(sticker);
  }
}
