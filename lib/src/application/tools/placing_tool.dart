import 'editor_tool.dart';
import 'editor_tool_context.dart';

abstract class PlacingTool extends EditorTool {
  PlacingTool({this.onPlaceError});

  final void Function(String error)? onPlaceError;

  @override
  void onCellHover(EditorToolContext context) {
    context.onHover?.call(context.row, context.col);
  }

  @override
  bool onCellTap(EditorToolContext context) {
    final error = context.controller.placeAt(context.row, context.col);
    if (error != null) {
      onPlaceError?.call(error);
    }
    return true;
  }
}
