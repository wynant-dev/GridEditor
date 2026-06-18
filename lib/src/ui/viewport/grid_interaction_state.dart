import 'package:flutter/foundation.dart';

/// Transient pointer/tool interaction state for the grid canvas.
class GridInteractionState extends ChangeNotifier {
  GridInteractionState({String? selectedItemId})
      : _selectedItemId = selectedItemId;

  int? _hoverRow;
  int? _hoverCol;
  String? _selectedItemId;

  int? get hoverRow => _hoverRow;
  int? get hoverCol => _hoverCol;
  String? get selectedItemId => _selectedItemId;

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
}
