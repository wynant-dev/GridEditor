import '../../domain/layout/item.dart';
import '../../domain/layout/sticker.dart';
import 'editor_tool_context.dart';
import 'placing_tool.dart';

class DefaultTool extends PlacingTool {
  DefaultTool({super.onPlaceError});

  @override
  bool onItemTap(EditorToolContext context, Item item) {
    context.controller.selectItem(item.id);
    return true;
  }

  @override
  bool onStickerTap(EditorToolContext context, Sticker sticker) {
    context.controller.selectSticker(sticker.id);
    return true;
  }
}
