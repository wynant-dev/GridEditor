import '../../domain/layout/placed_item.dart';
import '../../domain/layout/placed_sticker.dart';
import 'editor_tool.dart';
import 'editor_tool_context.dart';

class StickerTool extends EditorTool {
  StickerTool({this.onPlaceError});

  final void Function(String error)? onPlaceError;

  @override
  void onCellHover(EditorToolContext context) {
    context.onHoverWorld?.call(context.worldPosition);
  }

  @override
  bool onWorldTap(EditorToolContext context) {
    final error = context.controller.placeStickerAt(
      worldCenter: context.worldPosition,
      cellSize: context.cellSize,
      origin: context.origin,
    );
    if (error != null) {
      onPlaceError?.call(error);
    }
    return true;
  }

  @override
  bool onStickerTap(EditorToolContext context, PlacedSticker sticker) =>
      false;
}
