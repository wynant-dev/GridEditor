import 'package:flutter/foundation.dart';

import '../domain/catalog/item_catalog.dart';
import '../domain/layout/grid_document.dart';
import '../domain/layout/placed_item.dart';
import '../ui/viewport/grid_interaction_state.dart';
import 'editor_engine.dart';
import 'placement_rules.dart';
import 'selection_state.dart';
import 'tools/default_tool.dart';
import 'tools/place_tool.dart';
import 'tools/tool_manager.dart';

/// Single source of truth for editor state: engine + UI selection.
class EditorController extends ChangeNotifier {
  EditorController({
    EditorEngine? engine,
    String? selectedItemId,
    void Function(String error)? onPlaceError,
  }) : _engine =
           engine ??
           EditorEngine(
             catalog: const ItemCatalog(id: 'default', name: 'My catalog'),
             layout: const GridDocument(rows: 64, cols: 64),
           ),
       _selectedItemId = selectedItemId,
       _toolManager = ToolManager(
         activeTool: PlaceTool(onPlaceError: onPlaceError),
         defaultTool: DefaultTool(onPlaceError: onPlaceError),
       );

  EditorEngine _engine;
  String? _selectedItemId;
  GridInteractionState? _interactionState;
  SelectionState _selection = const SelectionState();
  ToolManager _toolManager;

  EditorEngine get engine => _engine;
  ItemCatalog get catalog => _engine.catalog;
  GridDocument get layout => _engine.layout;
  String? get selectedItemId => _selectedItemId;
  SelectionState get selection => _selection;
  String? get selectedPlacementId => _selection.selectedPlacementId;
  ToolManager get toolManager => _toolManager;

  PlacedItem? get selectedPlacement {
    final id = selectedPlacementId;
    if (id == null) return null;
    return _engine.placementById(id);
  }

  void configurePlaceError(void Function(String error)? onPlaceError) {
    final activeTool = _toolManager.activeTool;
    _toolManager = ToolManager(
      activeTool: activeTool is PlaceTool
          ? PlaceTool(onPlaceError: onPlaceError)
          : activeTool,
      defaultTool: DefaultTool(onPlaceError: onPlaceError),
    );
  }

  void loadCatalog(ItemCatalog catalog) {
    _engine = _engine.copyWith(catalog: catalog);
    _selectedItemId = catalog.items.isNotEmpty ? catalog.items.first.id : null;
    notifyListeners();
  }

  void selectItem(String itemId) {
    _selectedItemId = itemId;
    _selection = const SelectionState();
    notifyListeners();
  }

  void selectPlacement(String placementId) {
    _selection = _selection.copyWith(selectedPlacementId: placementId);
    _selectedItemId = null;
    notifyListeners();
  }

  void clearSelection() {
    _selection = const SelectionState();
    notifyListeners();
  }

  void attachInteractionState(GridInteractionState state) {
    _interactionState = state;
  }

  void setHoverCell(int row, int col) {
    _interactionState?.setHoverCell(row, col);
  }

  void clearHover() {
    _interactionState?.setHoverCell(null, null);
  }

  /// Places the selected catalog item centered on [row]/[col].
  /// Returns an error message on failure.
  String? placeAt(int row, int col) {
    final selectedId = _selectedItemId;
    if (selectedId == null) return null;

    final item = _engine.catalog.itemById(selectedId);
    if (item == null) return 'Unknown item: $selectedId';

    final (originRow, originCol) = PlacementRules.originFromCenterAnchor(
      layout: _engine.layout,
      item: item,
      anchorRow: row,
      anchorCol: col,
    );

    try {
      _engine = _engine.placeItem(
        catalogItemId: selectedId,
        originRow: originRow,
        originCol: originCol,
      );
      notifyListeners();
      return null;
    } on StateError catch (error) {
      return error.message;
    }
  }

  void removePlacement(PlacedItem placement) {
    _engine = _engine.removePlacement(placement.id);
    if (_selection.selectedPlacementId == placement.id) {
      _selection = const SelectionState();
    }
    notifyListeners();
  }

  /// Moves a placement to a new origin. Returns false when the move is invalid.
  bool movePlacement({
    required String placementId,
    required int newRow,
    required int newCol,
  }) {
    try {
      _engine = _engine.movePlacement(
        placementId: placementId,
        newRow: newRow,
        newCol: newCol,
      );
      notifyListeners();
      return true;
    } on StateError {
      return false;
    }
  }

  @override
  void dispose() {
    _toolManager.dispose();
    super.dispose();
  }
}
