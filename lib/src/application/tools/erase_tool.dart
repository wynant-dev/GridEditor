import '../../domain/layout/placed_item.dart';
import 'editor_tool.dart';
import 'editor_tool_context.dart';

class EraseTool extends EditorTool {
  @override
  bool onPlacementTap(EditorToolContext context, PlacedItem placement) {
    context.controller.removePlacement(placement);
    return true;
  }
}
