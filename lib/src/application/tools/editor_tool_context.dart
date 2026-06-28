import 'dart:ui';

import '../editor_controller.dart';
import '../editor_engine.dart';

class EditorToolContext {
  const EditorToolContext({
    required this.row,
    required this.col,
    required this.worldPosition,
    required this.cellSize,
    required this.origin,
    required this.controller,
    required this.engine,
    this.onHover,
    this.onHoverWorld,
    this.onClearHover,
    this.isPointerDown = false,
  });

  final int row;
  final int col;
  final Offset worldPosition;
  final double cellSize;
  final Offset origin;
  final EditorController controller;
  final EditorEngine engine;
  final void Function(int row, int col)? onHover;
  final void Function(Offset worldPosition)? onHoverWorld;
  final void Function()? onClearHover;
  final bool isPointerDown;
}
