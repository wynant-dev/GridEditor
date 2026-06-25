import 'package:flutter/foundation.dart';

import '../domain/catalog/catalog.dart';
import '../domain/layout/grid_document.dart';
import '../domain/layout/placed_item.dart';
import 'editor_engine.dart';
import '../domain/placement/placement_rules.dart';
import 'selection_history_entry.dart';
import 'selection_state.dart';
import 'tools/default_tool.dart';
import 'tools/floor_tool.dart';
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
             catalog: const Catalog(id: 'default', name: 'My catalog'),
             layout: const GridDocument(rows:130, cols: 130),
           ),
       _selectedItemId = selectedItemId,
       _onPlaceError = onPlaceError,
       _toolManager = ToolManager(
         activeTool: PlaceTool(onPlaceError: onPlaceError),
         defaultTool: DefaultTool(onPlaceError: onPlaceError),
       );

  EditorEngine _engine;
  String? _selectedItemId;
  String? _selectedFloorId;
  SelectionState _selection = const SelectionState();
  final List<SelectionHistoryEntry> _selectionHistory = [];
  ToolManager _toolManager;
  void Function(String error)? _onPlaceError;

  EditorEngine get engine => _engine;
  Catalog get catalog => _engine.catalog;
  GridDocument get layout => _engine.layout;
  String? get selectedItemId => _selectedItemId;
  String? get selectedFloorId => _selectedFloorId;
  List<SelectionHistoryEntry> get selectionHistory =>
      List.unmodifiable(_selectionHistory);
  SelectionState get selection => _selection;
  String? get selectedPlacementId => _selection.selectedPlacementId;
  ToolManager get toolManager => _toolManager;

  PlacedItem? get selectedPlacement {
    final id = selectedPlacementId;
    if (id == null) return null;
    return _engine.placementById(id);
  }

  void configurePlaceError(void Function(String error)? onPlaceError) {
    _onPlaceError = onPlaceError;
    final activeTool = _toolManager.activeTool;
    final newActive = switch (activeTool) {
      PlaceTool() => PlaceTool(onPlaceError: onPlaceError),
      FloorTool() => FloorTool(onPaintError: onPlaceError),
      final tool => tool,
    };
    _toolManager = ToolManager(
      activeTool: newActive,
      defaultTool: DefaultTool(onPlaceError: onPlaceError),
    );
  }

  void _syncToolsFromSelection() {
    final onError = _onPlaceError;
    _toolManager = ToolManager(
      activeTool: _selectedFloorId != null
          ? FloorTool(onPaintError: onError)
          : PlaceTool(onPlaceError: onError),
      defaultTool: DefaultTool(onPlaceError: onError),
    );
  }

  void loadCatalog(Catalog catalog) {
    _engine = _engine.copyWith(catalog: catalog);
    _selectedItemId = null;
    _selectedFloorId = null;
    _selection = const SelectionState();
    _selectionHistory.clear();
    _syncToolsFromSelection();
    notifyListeners();
  }

  void selectItem(String itemId) {
    _selectedItemId = itemId;
    _selectedFloorId = null;
    _selection = const SelectionState();
    _syncToolsFromSelection();
    notifyListeners();
  }

  void selectFloor(String floorId) {
    _selectedFloorId = floorId;
    _selectedItemId = null;
    _selection = const SelectionState();
    _syncToolsFromSelection();
    notifyListeners();
  }

  void reselectFromHistory(SelectionHistoryEntry entry) {
    switch (entry.kind) {
      case SelectionKind.item:
        selectItem(entry.id);
      case SelectionKind.floor:
        selectFloor(entry.id);
    }
  }

  void _pushHistory(SelectionHistoryEntry entry) {
    _selectionHistory.remove(entry);
    _selectionHistory.insert(0, entry);
    if (_selectionHistory.length > 3) {
      _selectionHistory.removeLast();
    }
  }

  void selectPlacement(String placementId) {
    _selection = _selection.copyWith(selectedPlacementId: placementId);
    _selectedItemId = null;
    _selectedFloorId = null;
    notifyListeners();
  }

  void clearSelection() {
    _selection = const SelectionState();
    notifyListeners();
  }

  /// Paints the selected floor onto [row]/[col].
  /// Returns an error message on failure.
  String? paintFloorAt(int row, int col) {
    final selectedId = _selectedFloorId;
    if (selectedId == null) return null;

    try {
      _engine = _engine.applyFloor(
        row: row,
        col: col,
        catalogFloorId: selectedId,
      );
      _pushHistory(SelectionHistoryEntry(kind: SelectionKind.floor, id: selectedId));
      notifyListeners();
      return null;
    } on StateError catch (error) {
      return error.message;
    }
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
      _pushHistory(SelectionHistoryEntry(kind: SelectionKind.item, id: selectedId));
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
