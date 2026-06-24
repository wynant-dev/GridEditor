import '../../domain/layout/placed_item.dart';
import 'editor_tool_context.dart';

abstract class EditorTool {
  bool onCellTap(EditorToolContext context) => false;

  bool onPlacementTap(
    EditorToolContext context,
    PlacedItem placement,
  ) =>
      false;

  void onCellHover(EditorToolContext context) {}

  bool canStartDrag(PlacedItem placement) => true;
}
