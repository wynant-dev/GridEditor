import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../domain/catalog/catalog.dart';
import '../domain/layout/grid_document.dart';
import '../domain/layout/item.dart';
import '../domain/layout/sticker.dart';
import 'editor_engine.dart';
import '../domain/rules/item_rules.dart';
import 'selection_history_entry.dart';
import 'selection_state.dart';
import 'editor_action_log.dart';
import 'tools/default_tool.dart';
import 'tools/floor_tool.dart';
import 'tools/place_tool.dart';
import 'tools/sticker_tool.dart';
import 'tools/tool_manager.dart';

/// Single source of truth for editor state: engine + UI selection.
class EditorController extends ChangeNotifier {
  EditorController({
    EditorEngine? engine,
    String? selectedCatalogItemId,
    void Function(String error)? onPlaceError,
    EditorActionLog? actionLog,
  }) : _engine =
           engine ??
           EditorEngine(
             catalog: const Catalog(id: 'default', name: 'My catalog'),
             layout: const GridDocument(
               rows: 130,
               cols: 130,
               defaultFloorId: 'grass',
             ),
           ),
       _selectedCatalogItemId = selectedCatalogItemId,
       _onPlaceError = onPlaceError,
       _actionLog = actionLog ?? EditorActionLog(),
       _toolManager = ToolManager(
         activeTool: PlaceTool(onPlaceError: onPlaceError),
         defaultTool: DefaultTool(onPlaceError: onPlaceError),
       );

  EditorEngine _engine;
  String? _selectedCatalogItemId;
  String? _selectedCatalogFloorId;
  String? _selectedCatalogStickerId;
  SelectionState _selection = const SelectionState();
  final List<SelectionHistoryEntry> _selectionHistory = [];
  ToolManager _toolManager;
  void Function(String error)? _onPlaceError;
  final EditorActionLog _actionLog;

  EditorEngine get engine => _engine;
  Catalog get catalog => _engine.catalog;
  GridDocument get layout => _engine.layout;

  /// Catalog template selected for placing new items.
  String? get selectedCatalogItemId => _selectedCatalogItemId;

  String? get selectedCatalogFloorId => _selectedCatalogFloorId;
  String? get selectedCatalogStickerId => _selectedCatalogStickerId;

  /// Grid [Item] instance selected on the canvas.
  String? get selectedItemId => _selection.selectedItemId;

  String? get selectedStickerId => _selection.selectedStickerId;
  List<SelectionHistoryEntry> get selectionHistory =>
      List.unmodifiable(_selectionHistory);
  SelectionState get selection => _selection;
  ToolManager get toolManager => _toolManager;
  EditorActionLog get actionLog => _actionLog;

  Item? get selectedItem {
    final id = selectedItemId;
    if (id == null) return null;
    return _engine.itemById(id);
  }

  Sticker? get selectedSticker {
    final id = selectedStickerId;
    if (id == null) return null;
    return _engine.stickerById(id);
  }

  void configurePlaceError(void Function(String error)? onPlaceError) {
    _onPlaceError = onPlaceError;
    final activeTool = _toolManager.activeTool;
    final newActive = switch (activeTool) {
      PlaceTool() => PlaceTool(onPlaceError: onPlaceError),
      FloorTool() => FloorTool(onPaintError: onPlaceError),
      StickerTool() => StickerTool(onPlaceError: onPlaceError),
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
      activeTool: switch (null) {
        _ when _selectedCatalogFloorId != null => FloorTool(onPaintError: onError),
        _ when _selectedCatalogStickerId != null =>
          StickerTool(onPlaceError: onError),
        _ => PlaceTool(onPlaceError: onError),
      },
      defaultTool: DefaultTool(onPlaceError: onError),
    );
  }

  void loadCatalog(Catalog catalog) {
    _engine = _engine.copyWith(catalog: catalog);
    _selectedCatalogItemId = null;
    _selectedCatalogFloorId = null;
    _selectedCatalogStickerId = null;
    _selection = const SelectionState();
    _selectionHistory.clear();
    _actionLog.clear();
    _syncToolsFromSelection();
    notifyListeners();
  }

  void selectCatalogItem(String catalogItemId) {
    _selectedCatalogItemId = catalogItemId;
    _selectedCatalogFloorId = null;
    _selectedCatalogStickerId = null;
    _selection = const SelectionState();
    _syncToolsFromSelection();
    notifyListeners();
  }

  void selectCatalogFloor(String floorId) {
    _selectedCatalogFloorId = floorId;
    _selectedCatalogItemId = null;
    _selectedCatalogStickerId = null;
    _selection = const SelectionState();
    _syncToolsFromSelection();
    notifyListeners();
  }

  void selectCatalogSticker(String stickerId) {
    _selectedCatalogStickerId = stickerId;
    _selectedCatalogItemId = null;
    _selectedCatalogFloorId = null;
    _selection = const SelectionState();
    _syncToolsFromSelection();
    _pushHistory(SelectionHistoryEntry(kind: SelectionKind.sticker, id: stickerId));
    notifyListeners();
  }

  void reselectFromHistory(SelectionHistoryEntry entry) {
    switch (entry.kind) {
      case SelectionKind.item:
        selectCatalogItem(entry.id);
      case SelectionKind.floor:
        selectCatalogFloor(entry.id);
      case SelectionKind.sticker:
        selectCatalogSticker(entry.id);
    }
  }

  void _pushHistory(SelectionHistoryEntry entry) {
    _selectionHistory.remove(entry);
    _selectionHistory.insert(0, entry);
    if (_selectionHistory.length > 3) {
      _selectionHistory.removeLast();
    }
  }

  void selectItem(String itemId) {
    _selection = SelectionState(selectedItemId: itemId);
    _selectedCatalogItemId = null;
    _selectedCatalogFloorId = null;
    _selectedCatalogStickerId = null;
    _syncToolsFromSelection();
    notifyListeners();
  }

  void selectSticker(String stickerId) {
    _selection = SelectionState(selectedStickerId: stickerId);
    _selectedCatalogItemId = null;
    _selectedCatalogFloorId = null;
    _selectedCatalogStickerId = null;
    _syncToolsFromSelection();
    notifyListeners();
  }

  void clearSelection() {
    _selection = const SelectionState();
    notifyListeners();
  }

  String _catalogItemLabel(String id) =>
      _engine.catalog.itemById(id)?.name ?? id;

  String _floorLabel(String id) => _engine.catalog.floorById(id)?.name ?? id;

  String _catalogStickerLabel(String id) =>
      _engine.catalog.stickerById(id)?.name ?? id;

  String _cellCoords(int row, int col) => '($row, $col)';

  String _worldCoords(double x, double y) =>
      '(${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)})';

  void _recordAction({required bool success, required String message}) {
    _actionLog.record(success: success, message: message);
  }

  /// Paints the selected floor onto [row]/[col].
  /// Returns an error message on failure.
  String? paintFloorAt(int row, int col) {
    final selectedId = _selectedCatalogFloorId;
    if (selectedId == null) return null;

    try {
      _engine = _engine.applyFloor(
        row: row,
        col: col,
        catalogFloorId: selectedId,
      );
      _pushHistory(SelectionHistoryEntry(kind: SelectionKind.floor, id: selectedId));
      _recordAction(
        success: true,
        message:
            'Painted - ${_floorLabel(selectedId)} ${_cellCoords(row, col)}',
      );
      notifyListeners();
      return null;
    } on StateError catch (error) {
      _recordAction(
        success: false,
        message:
            'Paint failed - ${_floorLabel(selectedId)} ${_cellCoords(row, col)}: '
            '${error.message}',
      );
      return error.message;
    }
  }

  /// Places the selected catalog item centered on [row]/[col].
  /// Returns an error message on failure.
  String? placeAt(int row, int col) {
    final selectedId = _selectedCatalogItemId;
    if (selectedId == null) return null;

    final catalogItem = _engine.catalog.itemById(selectedId);
    if (catalogItem == null) {
      final error = 'Unknown catalog item: $selectedId';
      _recordAction(
        success: false,
        message:
            'Place failed - $selectedId ${_cellCoords(row, col)}: $error',
      );
      return error;
    }

    final (originRow, originCol) = ItemRules.originFromCenterAnchor(
      layout: _engine.layout,
      catalogItem: catalogItem,
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
      _recordAction(
        success: true,
        message:
            'Placed - ${_catalogItemLabel(selectedId)} '
            '${_cellCoords(originRow, originCol)}',
      );
      notifyListeners();
      return null;
    } on StateError catch (error) {
      _recordAction(
        success: false,
        message:
            'Place failed - ${_catalogItemLabel(selectedId)} '
            '${_cellCoords(originRow, originCol)}: ${error.message}',
      );
      return error.message;
    }
  }

  /// Places the selected catalog sticker at [worldCenter].
  /// Returns an error message on failure.
  String? placeStickerAt({
    required Offset worldCenter,
    required double cellSize,
    required Offset origin,
  }) {
    final selectedId = _selectedCatalogStickerId;
    if (selectedId == null) return null;

    try {
      _engine = _engine.placeSticker(
        catalogStickerId: selectedId,
        x: worldCenter.dx,
        y: worldCenter.dy,
        cellSize: cellSize,
        origin: origin,
      );
      _recordAction(
        success: true,
        message:
            'Placed sticker - ${_catalogStickerLabel(selectedId)} '
            '${_worldCoords(worldCenter.dx, worldCenter.dy)}',
      );
      notifyListeners();
      return null;
    } on StateError catch (error) {
      _recordAction(
        success: false,
        message:
            'Place sticker failed - ${_catalogStickerLabel(selectedId)} '
            '${_worldCoords(worldCenter.dx, worldCenter.dy)}: ${error.message}',
      );
      return error.message;
    }
  }

  void removeItem(Item item) {
    final current = _engine.itemById(item.id) ?? item;
    _recordAction(
      success: true,
      message:
          'Deleted - ${_catalogItemLabel(current.catalogItemId)} '
          '${_cellCoords(current.originRow, current.originCol)}',
    );
    _engine = _engine.removeItem(item.id);
    if (_selection.selectedItemId == item.id) {
      _selection = const SelectionState();
    }
    notifyListeners();
  }

  void removeSticker(Sticker sticker) {
    final current = _engine.stickerById(sticker.id) ?? sticker;
    _recordAction(
      success: true,
      message:
          'Deleted sticker - ${_catalogStickerLabel(current.catalogStickerId)} '
          '${_worldCoords(current.x, current.y)}',
    );
    _engine = _engine.removeSticker(sticker.id);
    if (_selection.selectedStickerId == sticker.id) {
      _selection = const SelectionState();
    }
    notifyListeners();
  }

  /// Moves an item to a new origin. Returns false when the move is invalid.
  bool moveItem({
    required String itemId,
    required int newRow,
    required int newCol,
  }) {
    final existing = _engine.itemById(itemId);
    final label = existing == null
        ? itemId
        : _catalogItemLabel(existing.catalogItemId);

    try {
      _engine = _engine.moveItem(
        itemId: itemId,
        newRow: newRow,
        newCol: newCol,
      );
      _recordAction(
        success: true,
        message: 'Moved - $label ${_cellCoords(newRow, newCol)}',
      );
      notifyListeners();
      return true;
    } on StateError catch (error) {
      _recordAction(
        success: false,
        message:
            'Move failed - $label ${_cellCoords(newRow, newCol)}: '
            '${error.message}',
      );
      return false;
    }
  }

  /// Moves a sticker to a new center. Returns false when the move is invalid.
  bool moveSticker({
    required String stickerId,
    required double x,
    required double y,
    required double cellSize,
    required Offset origin,
  }) {
    final existing = _engine.stickerById(stickerId);
    final label = existing == null
        ? stickerId
        : _catalogStickerLabel(existing.catalogStickerId);

    try {
      _engine = _engine.moveSticker(
        stickerId: stickerId,
        x: x,
        y: y,
        cellSize: cellSize,
        origin: origin,
      );
      _recordAction(
        success: true,
        message: 'Moved sticker - $label ${_worldCoords(x, y)}',
      );
      notifyListeners();
      return true;
    } on StateError catch (error) {
      _recordAction(
        success: false,
        message:
            'Move sticker failed - $label ${_worldCoords(x, y)}: '
            '${error.message}',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _toolManager.dispose();
    _actionLog.dispose();
    super.dispose();
  }
}
