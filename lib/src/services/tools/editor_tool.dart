import 'grid_tool_context.dart';

abstract class EditorTool {
  void onCellHover(GridToolContext ctx);
  void onCellTap(GridToolContext ctx);
}
