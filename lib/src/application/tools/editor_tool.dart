import '../../domain/layout/item.dart';
import '../../domain/layout/sticker.dart';
import 'editor_tool_context.dart';

abstract class EditorTool {
  bool onCellTap(EditorToolContext context) => false;

  bool onItemTap(
    EditorToolContext context,
    Item item,
  ) =>
      false;

  bool onStickerTap(
    EditorToolContext context,
    Sticker sticker,
  ) =>
      false;

  bool onWorldTap(EditorToolContext context) => false;

  void onCellHover(EditorToolContext context) {}

  void onPointerUp() {}

  bool canStartDrag(Item item) => true;

  bool canStartStickerDrag(Sticker sticker) => true;
}
