import '../editor_controller.dart';
import '../editor_engine.dart';

class EditorToolContext {
  const EditorToolContext({
    required this.row,
    required this.col,
    required this.controller,
    required this.engine,
    this.onHover,
    this.onClearHover,
    this.isPointerDown = false,
  });

  final int row;
  final int col;
  final EditorController controller;
  final EditorEngine engine;
  final void Function(int row, int col)? onHover;
  final void Function()? onClearHover;
  final bool isPointerDown;
}
