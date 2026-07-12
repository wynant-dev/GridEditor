import '../../domain/layout/item.dart';
import 'editor_tool.dart';
import 'editor_tool_context.dart';

class EraseTool extends EditorTool {
  @override
  bool onItemTap(EditorToolContext context, Item item) {
    context.controller.removeItem(item);
    return true;
  }
}
