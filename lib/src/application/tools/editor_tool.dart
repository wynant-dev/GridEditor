import '../../domain/layout/placed_item.dart';
import '../../domain/layout/placed_sticker.dart';
import 'editor_tool_context.dart';

abstract class EditorTool {
  bool onCellTap(EditorToolContext context) => false;

  bool onPlacementTap(
    EditorToolContext context,
    PlacedItem placement,
  ) =>
      false;

  bool onStickerTap(
    EditorToolContext context,
    PlacedSticker sticker,
  ) =>
      false;

  bool onWorldTap(EditorToolContext context) => false;

  void onCellHover(EditorToolContext context) {}

  void onPointerUp() {}

  bool canStartDrag(PlacedItem placement) => true;

  bool canStartStickerDrag(PlacedSticker sticker) => true;
}
