import '../../domain/layout/placed_item.dart';
import 'editor_tool_context.dart';
import 'placing_tool.dart';

class DefaultTool extends PlacingTool {
  DefaultTool({super.onPlaceError});

  @override
  bool onPlacementTap(EditorToolContext context, PlacedItem placement) {
    context.controller.selectPlacement(placement.id);
    return true;
  }
}
