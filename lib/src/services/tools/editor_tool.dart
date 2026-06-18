import '../../domain/layout/placed_item.dart';
import 'grid_tool_context.dart';

abstract class EditorTool {
  bool onCellTap(GridToolContext context) => false;

  bool onPlacementTap(
    GridToolContext context,
    PlacedItem placement,
  ) =>
      false;

  void onCellHover(GridToolContext context) {}
}
