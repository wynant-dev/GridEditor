import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/item.dart';
import '../../domain/layout/sticker.dart';
import '../../domain/rules/sticker_rules.dart';
import '../../application/editor_controller.dart';
import '../../application/interaction/sticker_drag_session.dart';
import '../../application/tools/editor_tool_context.dart';
import '../../application/tools/tool_manager.dart';
import '../../domain/geometry/grid_coordinate_mapper.dart';
import '../../application/interaction/drag_session.dart';
import 'grid_hit.dart';
import 'grid_hit_tester.dart';
import 'grid_interaction_state.dart';

/// Handles pointer events for the grid canvas and resolves cell/item/sticker taps.
class GridInteractionHandler {
  GridInteractionHandler({
    required GridCoordinateMapper mapper,
    required GridDocument document,
    required Catalog catalog,
    required GridInteractionState interactionState,
    this.editorController,
    this.toolManager,
    this.onCellTap,
    this.onItemTap,
    this.supportsHover = true,
  })  : _mapper = mapper,
        _document = document,
        _catalog = catalog,
        interactionState = interactionState;

  GridCoordinateMapper _mapper;
  GridDocument _document;
  Catalog _catalog;
  final GridInteractionState interactionState;
  EditorController? editorController;
  ToolManager? toolManager;
  void Function(int row, int col)? onCellTap;
  void Function(Item item)? onItemTap;
  bool supportsHover;

  static const _tapSlop = 18.0;
  static const _longPressDuration = Duration(milliseconds: 500);

  int? _activePointerId;
  Offset? _pointerDownPosition;
  Item? _pointerDownItem;
  Sticker? _pointerDownSticker;
  int? _grabOffsetRow;
  int? _grabOffsetCol;
  Offset? _stickerGrabOffset;
  DragSession? _dragSession;
  StickerDragSession? _stickerDragSession;
  Timer? _longPressTimer;

  bool get isDragging =>
      _dragSession != null || _stickerDragSession != null;

  GridHitTester get _hitTester => GridHitTester(
        mapper: _mapper,
        document: _document,
        catalog: _catalog,
      );

  void updateContext({
    required GridCoordinateMapper mapper,
    required GridDocument document,
    required Catalog catalog,
    EditorController? editorController,
    ToolManager? toolManager,
    void Function(int row, int col)? onCellTap,
    void Function(Item item)? onItemTap,
    bool? supportsHover,
  }) {
    _mapper = mapper;
    _document = document;
    _catalog = catalog;
    this.editorController = editorController;
    this.toolManager = toolManager;
    this.onCellTap = onCellTap;
    this.onItemTap = onItemTap;
    if (supportsHover != null) {
      this.supportsHover = supportsHover;
    }
  }

  void handlePointerHover(PointerHoverEvent event) {
    if (!supportsHover) return;
    _handlePointerHover(event.localPosition);
  }

  void handlePointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) return;
    _activePointerId = event.pointer;
    _pointerDownPosition = event.localPosition;

    final world = _hitTester.worldAt(event.localPosition);
    _pointerDownSticker = _mapper.hitTestSticker(world, _document, _catalog);
    _pointerDownItem = _pointerDownSticker == null
        ? _mapper.hitTestItem(world, _document, _catalog)
        : null;

    _grabOffsetRow = null;
    _grabOffsetCol = null;
    _stickerGrabOffset = null;
    _cancelLongPressTimer();

    final sticker = _pointerDownSticker;
    if (sticker != null) {
      _stickerGrabOffset = world - Offset(sticker.x, sticker.y);
      _longPressTimer = Timer(_longPressDuration, () {
        if (_activePointerId == null || _stickerDragSession != null) return;
        _startStickerDrag(sticker, event.localPosition);
      });
    }

    final layoutItem = _pointerDownItem;
    if (layoutItem != null) {
      final (pointerRow, pointerCol) = _hitTester.cellAt(event.localPosition);
      _grabOffsetRow = pointerRow - layoutItem.originRow;
      _grabOffsetCol = pointerCol - layoutItem.originCol;
      _longPressTimer = Timer(_longPressDuration, () {
        if (_activePointerId == null || _dragSession != null) return;
        _startDrag(layoutItem, event.localPosition);
      });
    }

    _handlePointerHover(event.localPosition);
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (_activePointerId == event.pointer &&
        _pointerDownPosition != null &&
        _pointerDownSticker != null &&
        _stickerDragSession == null) {
      final distance = (event.localPosition - _pointerDownPosition!).distance;
      if (distance > _tapSlop) {
        _cancelLongPressTimer();
        _startStickerDrag(_pointerDownSticker!, event.localPosition);
      }
    }

    if (_activePointerId == event.pointer &&
        _pointerDownPosition != null &&
        _pointerDownItem != null &&
        _dragSession == null) {
      final distance = (event.localPosition - _pointerDownPosition!).distance;
      if (distance > _tapSlop) {
        _cancelLongPressTimer();
        _startDrag(_pointerDownItem!, event.localPosition);
      }
    }

    if (_stickerDragSession != null) {
      final world = _hitTester.worldAt(event.localPosition);
      final grabOffset = _stickerDragSession!.grabOffset;
      final center = _clampStickerCenter(world - grabOffset);
      interactionState.updateStickerDragPosition(center);
      return;
    }

    if (_dragSession != null) {
      final (pointerRow, pointerCol) = _hitTester.cellAt(event.localPosition);
      final origin = _originFromPointer(
        pointerRow: pointerRow,
        pointerCol: pointerCol,
        grabOffsetRow: _dragSession!.grabOffsetRow,
        grabOffsetCol: _dragSession!.grabOffsetCol,
        layoutItem: _document.itemById(_dragSession!.itemId),
      );
      interactionState.updateDragPosition(origin.$1, origin.$2);
      return;
    }

    _handlePointerHover(event.localPosition);
  }

  void handlePointerUp(PointerUpEvent event) {
    if (_activePointerId != event.pointer) {
      _clearDragSessionsIfIdle();
      return;
    }

    if (_pointerDownPosition == null) {
      _clearDragSessionsIfIdle();
      return;
    }

    _cancelLongPressTimer();

    final wasItemDragging = _dragSession != null;
    final wasStickerDragging = _stickerDragSession != null;
    if (wasItemDragging) {
      _resolveItemDragEnd();
    }
    if (wasStickerDragging) {
      _resolveStickerDragEnd();
    }

    toolManager?.handlePointerUp();

    final downPosition = _pointerDownPosition!;
    _activePointerId = null;
    _pointerDownPosition = null;
    _pointerDownItem = null;
    _pointerDownSticker = null;
    _grabOffsetRow = null;
    _grabOffsetCol = null;
    _stickerGrabOffset = null;
    _dragSession = null;
    _stickerDragSession = null;

    if (wasItemDragging || wasStickerDragging) {
      return;
    }

    if ((event.localPosition - downPosition).distance > _tapSlop) {
      return;
    }

    _resolveTap(event.localPosition);
  }

  void handlePointerCancel(PointerCancelEvent event) {
    if (_activePointerId == event.pointer) {
      _cancelLongPressTimer();
      toolManager?.handlePointerUp();
      _activePointerId = null;
      _pointerDownPosition = null;
      _pointerDownItem = null;
      _pointerDownSticker = null;
      _grabOffsetRow = null;
      _grabOffsetCol = null;
      _stickerGrabOffset = null;
      if (_dragSession != null) {
        interactionState.clearDragSession();
        _dragSession = null;
      }
      if (_stickerDragSession != null) {
        interactionState.clearStickerDragSession();
        _stickerDragSession = null;
      }
    }
  }

  void handleHoverExit() {
    _cancelLongPressTimer();
    _clearDragSessionsIfIdle();
    interactionState.setHoverCell(null, null);
    interactionState.setHoverWorldPosition(null);
  }

  void _startDrag(Item item, Offset viewportPosition) {
    if (!_canStartItemDrag(item)) return;

    final editorController = this.editorController;
    if (editorController != null &&
        editorController.selectedItemId != item.id) {
      editorController.selectItem(item.id);
    }

    final grabOffsetRow = _grabOffsetRow ?? 0;
    final grabOffsetCol = _grabOffsetCol ?? 0;
    final (pointerRow, pointerCol) = _hitTester.cellAt(viewportPosition);
    final origin = _originFromPointer(
      pointerRow: pointerRow,
      pointerCol: pointerCol,
      grabOffsetRow: grabOffsetRow,
      grabOffsetCol: grabOffsetCol,
      layoutItem: item,
    );
    final session = DragSession(
      itemId: item.id,
      startRow: item.originRow,
      startCol: item.originCol,
      grabOffsetRow: grabOffsetRow,
      grabOffsetCol: grabOffsetCol,
      currentRow: origin.$1,
      currentCol: origin.$2,
    );
    _dragSession = session;
    interactionState.startDragSession(session);
  }

  void _startStickerDrag(Sticker sticker, Offset viewportPosition) {
    if (!_canStartStickerDrag(sticker)) return;

    final editorController = this.editorController;
    if (editorController != null &&
        editorController.selectedStickerId != sticker.id) {
      editorController.selectSticker(sticker.id);
    }

    final world = _hitTester.worldAt(viewportPosition);
    final grabOffset = _stickerGrabOffset ?? world - Offset(sticker.x, sticker.y);
    final center = _clampStickerCenter(world - grabOffset);
    final session = StickerDragSession(
      stickerId: sticker.id,
      grabOffset: grabOffset,
      currentCenter: center,
    );
    _stickerDragSession = session;
    interactionState.startStickerDragSession(session);
  }

  bool _canStartItemDrag(Item item) {
    final toolManager = this.toolManager;
    if (toolManager != null) {
      return toolManager.canStartDrag(item);
    }
    return true;
  }

  bool _canStartStickerDrag(Sticker sticker) {
    final toolManager = this.toolManager;
    if (toolManager != null) {
      return toolManager.canStartStickerDrag(sticker);
    }
    return true;
  }

  Offset _clampStickerCenter(Offset center) {
    final metrics = _mapper.metrics;
    return StickerRules.clampCenter(
      rows: _document.rows,
      cols: _document.cols,
      cellSize: metrics.cellSize,
      origin: metrics.origin,
      center: center,
    );
  }

  (int row, int col) _originFromPointer({
    required int pointerRow,
    required int pointerCol,
    required int grabOffsetRow,
    required int grabOffsetCol,
    required Item? layoutItem,
  }) {
    var originRow = pointerRow - grabOffsetRow;
    var originCol = pointerCol - grabOffsetCol;

    if (layoutItem != null) {
      final catalogItem = _catalog.itemById(layoutItem.catalogItemId);
      if (catalogItem != null) {
        originRow = originRow.clamp(0, _document.rows - catalogItem.height);
        originCol = originCol.clamp(0, _document.cols - catalogItem.width);
      }
    }

    return (originRow, originCol);
  }

  void _resolveItemDragEnd() {
    final session = interactionState.dragSession ?? _dragSession;
    if (session == null) return;

    final editorController = this.editorController;
    if (editorController != null) {
      editorController.moveItem(
        itemId: session.itemId,
        newRow: session.currentRow,
        newCol: session.currentCol,
      );
    }

    interactionState.clearDragSession();
  }

  void _resolveStickerDragEnd() {
    final session = interactionState.stickerDragSession ?? _stickerDragSession;
    if (session == null) return;

    final editorController = this.editorController;
    if (editorController != null) {
      final metrics = _mapper.metrics;
      editorController.moveSticker(
        stickerId: session.stickerId,
        x: session.currentCenter.dx,
        y: session.currentCenter.dy,
        cellSize: metrics.cellSize,
        origin: metrics.origin,
      );
    }

    interactionState.clearStickerDragSession();
  }

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void _clearDragSessionsIfIdle() {
    if (_activePointerId != null) return;
    if (_dragSession == null &&
        _stickerDragSession == null &&
        !interactionState.isDragging) {
      return;
    }
    interactionState.clearDragSession();
    interactionState.clearStickerDragSession();
    _dragSession = null;
    _stickerDragSession = null;
  }

  void _handlePointerHover(Offset viewportPosition) {
    if (interactionState.isDragging) return;

    final (row, col) = _hitTester.cellAt(viewportPosition);
    final world = _hitTester.worldAt(viewportPosition);
    final toolManager = this.toolManager;
    final editorController = this.editorController;

    interactionState.setHoverCell(row, col);
    interactionState.setHoverWorldPosition(world);

    if (toolManager != null && editorController != null) {
      toolManager.handleCellHover(_toolContext(viewportPosition, row: row, col: col));
      return;
    }
  }

  EditorToolContext _toolContext(
    Offset viewportPosition, {
    required int row,
    required int col,
  }) {
    final editorController = this.editorController!;
    final metrics = _mapper.metrics;
    return EditorToolContext(
      row: row,
      col: col,
      worldPosition: _hitTester.worldAt(viewportPosition),
      cellSize: metrics.cellSize,
      origin: metrics.origin,
      controller: editorController,
      engine: editorController.engine,
      onHover: (row, col) => interactionState.setHoverCell(row, col),
      onHoverWorld: (position) =>
          interactionState.setHoverWorldPosition(position),
      isPointerDown: _activePointerId != null,
    );
  }

  void _resolveTap(Offset viewportPosition) {
    final toolManager = this.toolManager;
    final editorController = this.editorController;

    if (toolManager != null && editorController != null) {
      final hit = _hitTester.classifyTap(viewportPosition);
      final ctx = _toolContext(
        viewportPosition,
        row: switch (hit) {
          CellHit(:final row) => row,
          ItemHit(:final row) => row,
          StickerHit(:final row) => row,
        },
        col: switch (hit) {
          CellHit(:final col) => col,
          ItemHit(:final col) => col,
          StickerHit(:final col) => col,
        },
      );

      switch (hit) {
        case StickerHit(:final sticker):
          toolManager.handleStickerTap(ctx, sticker);
        case ItemHit(:final item):
          toolManager.handleItemTap(ctx, item);
        case CellHit():
          if (!toolManager.handleWorldTap(ctx)) {
            toolManager.handleCellTap(ctx);
          }
      }
      return;
    }

    final world = _mapper.metrics.screenToWorld(viewportPosition);
    final sticker = _mapper.hitTestSticker(world, _document, _catalog);
    if (sticker != null) {
      return;
    }

    final layoutItem = _mapper.hitTestItem(
      world,
      _document,
      _catalog,
    );
    if (layoutItem != null) {
      onItemTap?.call(layoutItem);
      return;
    }

    final (row, col) = _mapper.fromLocalPosition(viewportPosition);
    onCellTap?.call(row, col);
  }
}
