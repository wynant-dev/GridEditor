import 'editor_tool.dart';
import 'grid_tool_context.dart';

class PlaceTool implements EditorTool {
  PlaceTool({this.onPlaceError});

  final void Function(String error)? onPlaceError;

  @override
  void onCellHover(GridToolContext ctx) {
    ctx.controller.setHoverCell(ctx.row, ctx.col);
  }

  @override
  void onCellTap(GridToolContext ctx) {
    final error = ctx.controller.placeAt(ctx.row, ctx.col);
    if (error != null) {
      onPlaceError?.call(error);
    }
  }
}
