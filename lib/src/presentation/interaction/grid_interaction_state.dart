import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../application/interaction/drag_session.dart';
import '../../application/interaction/sticker_drag_session.dart';

/// Transient pointer/tool interaction state for the grid canvas.
class GridInteractionState extends ChangeNotifier {
  int? _hoverRow;
  int? _hoverCol;
  Offset? _hoverWorldPosition;
  DragSession? _dragSession;
  StickerDragSession? _stickerDragSession;

  int? get hoverRow => _hoverRow;
  int? get hoverCol => _hoverCol;
  Offset? get hoverWorldPosition => _hoverWorldPosition;
  DragSession? get dragSession => _dragSession;
  StickerDragSession? get stickerDragSession => _stickerDragSession;
  bool get isDragging => _dragSession != null || _stickerDragSession != null;

  void setHoverCell(int? row, int? col) {
    if (_hoverRow == row && _hoverCol == col) return;
    _hoverRow = row;
    _hoverCol = col;
    notifyListeners();
  }

  void setHoverWorldPosition(Offset? position) {
    if (_hoverWorldPosition == position) return;
    _hoverWorldPosition = position;
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

  void startStickerDragSession(StickerDragSession session) {
    _stickerDragSession = session;
    notifyListeners();
  }

  void updateStickerDragPosition(Offset center) {
    final session = _stickerDragSession;
    if (session == null) return;
    if (session.currentCenter == center) return;
    session.currentCenter = center;
    notifyListeners();
  }

  void clearStickerDragSession() {
    if (_stickerDragSession == null) return;
    _stickerDragSession = null;
    notifyListeners();
  }
}
