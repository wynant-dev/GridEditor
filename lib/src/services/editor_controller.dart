import 'package:flutter/foundation.dart';

import '../domain/catalog/item_catalog.dart';
import '../domain/layout/grid_document.dart';
import '../domain/layout/placed_item.dart';
import 'editor_engine.dart';

/// Single source of truth for editor state: engine + UI selection.
class EditorController extends ChangeNotifier {
  EditorController({
    EditorEngine? engine,
    String? selectedItemId,
  }) : _engine =
           engine ??
           EditorEngine(
             catalog: const ItemCatalog(id: 'default', name: 'My catalog'),
             layout: const GridDocument(rows: 12, cols: 12),
           ),
       _selectedItemId = selectedItemId;

  EditorEngine _engine;
  String? _selectedItemId;
  int? _hoverRow;
  int? _hoverCol;

  EditorEngine get engine => _engine;
  ItemCatalog get catalog => _engine.catalog;
  GridDocument get layout => _engine.layout;
  String? get selectedItemId => _selectedItemId;
  int? get hoverRow => _hoverRow;
  int? get hoverCol => _hoverCol;

  void loadCatalog(ItemCatalog catalog) {
    _engine = _engine.copyWith(catalog: catalog);
    _selectedItemId = catalog.items.isNotEmpty ? catalog.items.first.id : null;
    notifyListeners();
  }

  void selectItem(String itemId) {
    _selectedItemId = itemId;
    notifyListeners();
  }

  void setHoverCell(int? row, int? col) {
    if (_hoverRow == row && _hoverCol == col) return;
    _hoverRow = row;
    _hoverCol = col;
    notifyListeners();
  }

  /// Places the selected catalog item. Returns an error message on failure.
  String? placeAt(int row, int col) {
    final selectedId = _selectedItemId;
    if (selectedId == null) return null;

    try {
      _engine = _engine.placeItem(
        catalogItemId: selectedId,
        originRow: row,
        originCol: col,
      );
      notifyListeners();
      return null;
    } on StateError catch (error) {
      return error.message;
    }
  }

  void removePlacement(PlacedItem placement) {
    _engine = _engine.removePlacement(placement.id);
    notifyListeners();
  }
}
