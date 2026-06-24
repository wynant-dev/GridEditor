import 'package:flutter/foundation.dart';

import '../../application/interaction/drag_session.dart';

/// Transient pointer/tool interaction state for the grid canvas.
class GridInteractionState extends ChangeNotifier {
  int? _hoverRow;
  int? _hoverCol;
  DragSession? _dragSession;

  int? get hoverRow => _hoverRow;
  int? get hoverCol => _hoverCol;
  DragSession? get dragSession => _dragSession;
  bool get isDragging => _dragSession != null;

  void setHoverCell(int? row, int? col) {
    if (_hoverRow == row && _hoverCol == col) return;
    _hoverRow = row;
    _hoverCol = col;
    notifyListeners();
  }

  void startDragSession(DragSession session) {
    _dragSession = session;
    notifyListeners();
  }

  void updateDragPosition(int row, int col) {
    final session = _dragSession;
    if (session == null) return;
    if (session.currentRow == row && session.currentCol == col) return;
    session.currentRow = row;
    session.currentCol = col;
    notifyListeners();
  }

  void clearDragSession() {
    if (_dragSession == null) return;
    _dragSession = null;
    notifyListeners();
  }
}
