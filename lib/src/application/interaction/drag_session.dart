/// Tracks an in-progress item drag on the grid.
class DragSession {
  DragSession({
    required this.itemId,
    required this.startRow,
    required this.startCol,
    required this.grabOffsetRow,
    required this.grabOffsetCol,
    required this.currentRow,
    required this.currentCol,
  });

  final String itemId;
  final int startRow;
  final int startCol;

  /// Pointer cell minus item origin at drag start.
  final int grabOffsetRow;
  final int grabOffsetCol;

  int currentRow;
  int currentCol;
}
