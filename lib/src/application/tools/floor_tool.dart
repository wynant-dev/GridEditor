import '../../domain/layout/item.dart';
import 'editor_tool.dart';
import 'editor_tool_context.dart';

class FloorTool extends EditorTool {
  FloorTool({this.onPaintError});

  final void Function(String error)? onPaintError;

  int? _lastStrokeRow;
  int? _lastStrokeCol;

  @override
  void onPointerUp() {
    _lastStrokeRow = null;
    _lastStrokeCol = null;
  }

  @override
  void onCellHover(EditorToolContext context) {
    context.onHover?.call(context.row, context.col);
    if (!context.isPointerDown) return;
    _paintAt(context);
  }

  @override
  bool onCellTap(EditorToolContext context) {
    _paintAt(context);
    return true;
  }

  @override
  bool onItemTap(
    EditorToolContext context,
    Item item,
  ) {
    _paintAt(context);
    return true;
  }

  @override
  bool canStartDrag(Item item) => false;

  void _paintAt(EditorToolContext context) {
    if (_lastStrokeRow == context.row && _lastStrokeCol == context.col) {
      return;
    }
    _lastStrokeRow = context.row;
    _lastStrokeCol = context.col;

    final error = context.controller.paintFloorAt(context.row, context.col);
    if (error != null) {
      onPaintError?.call(error);
    }
  }
}
