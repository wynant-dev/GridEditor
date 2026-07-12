import '../../domain/layout/item.dart';
import 'editor_tool_context.dart';
import 'placing_tool.dart';

class PlaceTool extends PlacingTool {
  PlaceTool({super.onPlaceError});

  @override
  bool onItemTap(EditorToolContext context, Item item) => false;
}
