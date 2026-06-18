import '../../domain/layout/placed_item.dart';
import 'editor_tool.dart';
import 'grid_tool_context.dart';

class DefaultTool extends EditorTool {
  DefaultTool({this.onPlaceError});

  final void Function(String error)? onPlaceError;

  @override
  void onCellHover(GridToolContext context) {
    context.controller.setHoverCell(context.row, context.col);
  }

  @override
  bool onCellTap(GridToolContext context) {
    final error = context.controller.placeAt(context.row, context.col);
    if (error != null) {
      onPlaceError?.call(error);
    }
    return true;
  }

  @override
  bool onPlacementTap(GridToolContext context, PlacedItem placement) {
    context.controller.selectPlacement(placement.id);
    return true;
  }
}
