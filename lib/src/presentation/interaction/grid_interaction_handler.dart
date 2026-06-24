import 'dart:async';

import 'package:flutter/gestures.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../../application/editor_controller.dart';
import '../../application/tools/editor_tool_context.dart';
import '../../application/tools/tool_manager.dart';
import '../../domain/geometry/grid_coordinate_mapper.dart';
import '../../application/interaction/drag_session.dart';
import 'grid_hit.dart';
import 'grid_hit_tester.dart';
import 'grid_interaction_state.dart';

/// Handles pointer events for the grid canvas and resolves cell/placement taps.
class GridInteractionHandler {
  GridInteractionHandler({
    required GridCoordinateMapper mapper,
    required GridDocument document,
    required Catalog catalog,
    required GridInteractionState interactionState,
    this.editorController,
    this.toolManager,
    this.onCellTap,
    this.onPlacementTap,
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
  void Function(PlacedItem placement)? onPlacementTap;
  bool supportsHover;

  static const _tapSlop = 18.0;
  static const _longPressDuration = Duration(milliseconds: 500);

  int? _activePointerId;
  Offset? _pointerDownPosition;
  PlacedItem? _pointerDownPlacement;
  int? _grabOffsetRow;
  int? _grabOffsetCol;
  DragSession? _dragSession;
  Timer? _longPressTimer;

  bool get isDragging => _dragSession != null;

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
    void Function(PlacedItem placement)? onPlacementTap,
    bool? supportsHover,
  }) {
    _mapper = mapper;
    _document = document;
    _catalog = catalog;
    this.editorController = editorController;
    this.toolManager = toolManager;
    this.onCellTap = onCellTap;
    this.onPlacementTap = onPlacementTap;
    if (supportsHover != null) {
      this.supportsHover = supportsHover;
    }
  }

  void handlePointerHover(PointerHoverEvent event) {
    if (!supportsHover) return;
    _handleCellHover(event.localPosition);
  }

  void handlePointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) return;
    _activePointerId = event.pointer;
    _pointerDownPosition = event.localPosition;
    _pointerDownPlacement = _mapper.hitTestPlacement(
      event.localPosition,
      _document,
      _catalog,
    );
    _grabOffsetRow = null;
    _grabOffsetCol = null;
    _cancelLongPressTimer();

    final placement = _pointerDownPlacement;
    if (placement != null) {
      final (pointerRow, pointerCol) = _hitTester.cellAt(event.localPosition);
      _grabOffsetRow = pointerRow - placement.originRow;
      _grabOffsetCol = pointerCol - placement.originCol;
      _longPressTimer = Timer(_longPressDuration, () {
        if (_activePointerId == null || _dragSession != null) return;
        _startDrag(placement, event.localPosition);
      });
    }

    _handleCellHover(event.localPosition);
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (_activePointerId == event.pointer &&
        _pointerDownPosition != null &&
        _pointerDownPlacement != null &&
        _dragSession == null) {
      final distance = (event.localPosition - _pointerDownPosition!).distance;
      if (distance > _tapSlop) {
        _cancelLongPressTimer();
        _startDrag(_pointerDownPlacement!, event.localPosition);
      }
    }

    if (_dragSession != null) {
      final (pointerRow, pointerCol) = _hitTester.cellAt(event.localPosition);
      final origin = _originFromPointer(
        pointerRow: pointerRow,
        pointerCol: pointerCol,
        grabOffsetRow: _dragSession!.grabOffsetRow,
        grabOffsetCol: _dragSession!.grabOffsetCol,
        placement: _document.placementById(_dragSession!.placementId),
      );
      interactionState.updateDragPosition(origin.$1, origin.$2);
      return;
    }

    // Always follow the pointer during move — hover events are suppressed while
    // the primary button is down and on touch devices hover is unavailable.
    _handleCellHover(event.localPosition);
  }

  void handlePointerUp(PointerUpEvent event) {
    if (_activePointerId != event.pointer) {
      _clearDragSessionIfIdle();
      return;
    }

    if (_pointerDownPosition == null) {
      _clearDragSessionIfIdle();
      return;
    }

    _cancelLongPressTimer();

    final wasDragging = _dragSession != null;
    if (wasDragging) {
      _resolveDragEnd();
    }

    final downPosition = _pointerDownPosition!;
    _activePointerId = null;
    _pointerDownPosition = null;
    _pointerDownPlacement = null;
    _grabOffsetRow = null;
    _grabOffsetCol = null;
    _dragSession = null;

    if (wasDragging) {
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
      _activePointerId = null;
      _pointerDownPosition = null;
      _pointerDownPlacement = null;
      _grabOffsetRow = null;
      _grabOffsetCol = null;
      if (_dragSession != null) {
        interactionState.clearDragSession();
        _dragSession = null;
      }
    }
  }

  void handleHoverExit() {
    _cancelLongPressTimer();
    _clearDragSessionIfIdle();
    interactionState.setHoverCell(null, null);
  }

  void _startDrag(PlacedItem placement, Offset worldPosition) {
    if (!_canStartDrag(placement)) return;

    final editorController = this.editorController;
    if (editorController != null &&
        editorController.selectedPlacementId != placement.id) {
      editorController.selectPlacement(placement.id);
    }

    final grabOffsetRow = _grabOffsetRow ?? 0;
    final grabOffsetCol = _grabOffsetCol ?? 0;
    final (pointerRow, pointerCol) = _hitTester.cellAt(worldPosition);
    final origin = _originFromPointer(
      pointerRow: pointerRow,
      pointerCol: pointerCol,
      grabOffsetRow: grabOffsetRow,
      grabOffsetCol: grabOffsetCol,
      placement: placement,
    );
    final session = DragSession(
      placementId: placement.id,
      startRow: placement.originRow,
      startCol: placement.originCol,
      grabOffsetRow: grabOffsetRow,
      grabOffsetCol: grabOffsetCol,
      currentRow: origin.$1,
      currentCol: origin.$2,
    );
    _dragSession = session;
    interactionState.startDragSession(session);
  }

  bool _canStartDrag(PlacedItem placement) {
    final toolManager = this.toolManager;
    if (toolManager != null) {
      return toolManager.canStartDrag(placement);
    }
    return true;
  }

  (int row, int col) _originFromPointer({
    required int pointerRow,
    required int pointerCol,
    required int grabOffsetRow,
    required int grabOffsetCol,
    required PlacedItem? placement,
  }) {
    var originRow = pointerRow - grabOffsetRow;
    var originCol = pointerCol - grabOffsetCol;

    if (placement != null) {
      final item = _catalog.itemById(placement.catalogItemId);
      if (item != null) {
        originRow = originRow.clamp(0, _document.rows - item.height);
        originCol = originCol.clamp(0, _document.cols - item.width);
      }
    }

    return (originRow, originCol);
  }

  void _resolveDragEnd() {
    final session = interactionState.dragSession ?? _dragSession;
    if (session == null) return;

    final editorController = this.editorController;
    if (editorController != null) {
      editorController.movePlacement(
        placementId: session.placementId,
        newRow: session.currentRow,
        newCol: session.currentCol,
      );
    }

    interactionState.clearDragSession();
  }

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void _clearDragSessionIfIdle() {
    if (_activePointerId != null) return;
    if (_dragSession == null && !interactionState.isDragging) return;
    interactionState.clearDragSession();
    _dragSession = null;
  }

  void _handleCellHover(Offset worldPosition) {
    if (interactionState.isDragging) return;

    final (row, col) = _hitTester.cellAt(worldPosition);
    final toolManager = this.toolManager;
    final editorController = this.editorController;

    if (toolManager != null && editorController != null) {
      toolManager.handleCellHover(
        EditorToolContext(
          row: row,
          col: col,
          controller: editorController,
          engine: editorController.engine,
          onHover: (row, col) => interactionState.setHoverCell(row, col),
        ),
      );
      return;
    }

    interactionState.setHoverCell(row, col);
  }

  void _resolveTap(Offset worldPosition) {
    final toolManager = this.toolManager;
    final editorController = this.editorController;

    if (toolManager != null && editorController != null) {
      final hit = _hitTester.classifyTap(worldPosition);
      final ctx = EditorToolContext(
        row: switch (hit) {
          CellHit(:final row) => row,
          PlacementHit(:final row) => row,
        },
        col: switch (hit) {
          CellHit(:final col) => col,
          PlacementHit(:final col) => col,
        },
        controller: editorController,
        engine: editorController.engine,
        onHover: (row, col) => interactionState.setHoverCell(row, col),
      );

      switch (hit) {
        case PlacementHit(:final placement):
          toolManager.handlePlacementTap(ctx, placement);
        case CellHit():
          toolManager.handleCellTap(ctx);
      }
      return;
    }

    final placement = _mapper.hitTestPlacement(
      worldPosition,
      _document,
      _catalog,
    );
    if (placement != null) {
      onPlacementTap?.call(placement);
      return;
    }

    final (row, col) = _mapper.fromWorldPosition(worldPosition);
    onCellTap?.call(row, col);
  }
}
