import '../editor_controller.dart';
import '../editor_engine.dart';

class GridToolContext {
  const GridToolContext({
    required this.row,
    required this.col,
    required this.controller,
    required this.engine,
  });

  final int row;
  final int col;
  final EditorController controller;
  final EditorEngine engine;
}
