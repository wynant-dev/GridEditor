import 'dart:ui';

import 'package:flutter/gestures.dart';

import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../../services/editor_controller.dart';
import '../../services/tools/grid_tool_context.dart';
import '../../services/tools/tool_manager.dart';
import '../geometry/grid_coordinate_mapper.dart';
import '../viewport/grid_interaction_state.dart';
import 'grid_hit_tester.dart';

/// Handles pointer events for the grid canvas and resolves cell/placement taps.
class GridInteractionController {
  GridInteractionController({
    required this.mapper,
    required this.document,
    required this.catalog,
    required this.interactionState,
    this.editorController,
    this.toolManager,
    this.onCellTap,
    this.onPlacementTap,
    this.supportsHover = true,
  });

  final GridCoordinateMapper mapper;
  final GridDocument document;
  final ItemCatalog catalog;
  final GridInteractionState interactionState;
  final EditorController? editorController;
  final ToolManager? toolManager;
  final void Function(int row, int col)? onCellTap;
  final void Function(PlacedItem placement)? onPlacementTap;
  final bool supportsHover;

  static const _tapSlop = 18.0;

  int? _activePointerId;
  Offset? _pointerDownPosition;

  GridHitTester get _hitTester => GridHitTester(
    mapper: mapper,
    document: document,
    catalog: catalog,
  );

  void handlePointerHover(PointerHoverEvent event) {
    if (!supportsHover) return;
    _handleCellHover(event.localPosition);
  }

  void handlePointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) return;
    _activePointerId = event.pointer;
    _pointerDownPosition = event.localPosition;
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (!supportsHover) return;
    _handleCellHover(event.localPosition);
  }

  void handlePointerUp(PointerUpEvent event) {
    if (_activePointerId != event.pointer || _pointerDownPosition == null) {
      return;
    }

    final downPosition = _pointerDownPosition!;
    _activePointerId = null;
    _pointerDownPosition = null;

    if ((event.localPosition - downPosition).distance > _tapSlop) {
      return;
    }

    _resolveTap(event.localPosition);
  }

  void handlePointerCancel(PointerCancelEvent event) {
    if (_activePointerId == event.pointer) {
      _activePointerId = null;
      _pointerDownPosition = null;
    }
  }

  void handleHoverExit() {
    final controller = editorController;
    if (controller != null) {
      controller.clearHover();
      return;
    }
    interactionState.setHoverCell(null, null);
  }

  void _handleCellHover(Offset worldPosition) {
    final (row, col) = _hitTester.cellAt(worldPosition);
    final toolManager = this.toolManager;
    final editorController = this.editorController;

    if (toolManager != null && editorController != null) {
      toolManager.handleCellHover(
        GridToolContext(
          row: row,
          col: col,
          controller: editorController,
          engine: editorController.engine,
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
      final ctx = GridToolContext(
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
      );

      switch (hit) {
        case PlacementHit(:final placement):
          toolManager.handlePlacementTap(ctx, placement);
        case CellHit():
          toolManager.handleCellTap(ctx);
      }
      return;
    }

    final placement = mapper.hitTestPlacement(
      worldPosition,
      document,
      catalog,
    );
    if (placement != null) {
      onPlacementTap?.call(placement);
      return;
    }

    final (row, col) = mapper.fromWorldPosition(worldPosition);
    onCellTap?.call(row, col);
  }
}
