import '../../domain/layout/placed_item.dart';
import 'editor_tool_context.dart';
import 'placing_tool.dart';

class PlaceTool extends PlacingTool {
  PlaceTool({super.onPlaceError});

  @override
  bool onPlacementTap(EditorToolContext context, PlacedItem placement) => false;
}
