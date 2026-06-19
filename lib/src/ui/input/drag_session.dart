/// Tracks an in-progress placement drag interaction.
class DragSession {
  DragSession({
    required this.placementId,
    required this.startRow,
    required this.startCol,
    required this.grabOffsetRow,
    required this.grabOffsetCol,
    required this.currentRow,
    required this.currentCol,
  });

  final String placementId;
  final int startRow;
  final int startCol;

  /// Pointer cell minus placement origin at drag start.
  final int grabOffsetRow;
  final int grabOffsetCol;

  int currentRow;
  int currentCol;
}
