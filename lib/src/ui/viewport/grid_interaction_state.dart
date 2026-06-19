import 'package:flutter/foundation.dart';

import '../input/drag_session.dart';

/// Transient pointer/tool interaction state for the grid canvas.
class GridInteractionState extends ChangeNotifier {
  GridInteractionState({String? selectedItemId})
      : _selectedItemId = selectedItemId;

  int? _hoverRow;
  int? _hoverCol;
  String? _selectedItemId;
  DragSession? _dragSession;

  int? get hoverRow => _hoverRow;
  int? get hoverCol => _hoverCol;
  String? get selectedItemId => _selectedItemId;
  DragSession? get dragSession => _dragSession;
  bool get isDragging => _dragSession != null;

  void syncSelectedItemId(String? itemId) {
    _selectedItemId = itemId;
  }

  void setHoverCell(int? row, int? col) {
    if (_hoverRow == row && _hoverCol == col) return;
    _hoverRow = row;
    _hoverCol = col;
    notifyListeners();
  }

  void updateSelectedItemId(String? itemId) {
    if (_selectedItemId == itemId) return;
    _selectedItemId = itemId;
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
