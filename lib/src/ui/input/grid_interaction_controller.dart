import 'dart:ui';

import 'package:flutter/gestures.dart';

import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../geometry/grid_coordinate_mapper.dart';
import '../viewport/grid_interaction_state.dart';

/// Handles pointer events for the grid canvas and resolves cell/placement taps.
class GridInteractionController {
  GridInteractionController({
    required this.mapper,
    required this.document,
    required this.catalog,
    required this.interactionState,
    this.onCellTap,
    this.onPlacementTap,
    this.supportsHover = true,
  });

  final GridCoordinateMapper mapper;
  final GridDocument document;
  final ItemCatalog catalog;
  final GridInteractionState interactionState;
  final void Function(int row, int col)? onCellTap;
  final void Function(PlacedItem placement)? onPlacementTap;
  final bool supportsHover;

  static const _tapSlop = 18.0;

  int? _activePointerId;
  Offset? _pointerDownPosition;

  void handlePointerHover(PointerHoverEvent event) {
    if (!supportsHover) return;
    final (row, col) = mapper.fromWorldPosition(event.localPosition);
    interactionState.setHoverCell(row, col);
  }

  void handlePointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) return;
    _activePointerId = event.pointer;
    _pointerDownPosition = event.localPosition;
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (!supportsHover) return;
    final (row, col) = mapper.fromWorldPosition(event.localPosition);
    interactionState.setHoverCell(row, col);
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
    interactionState.setHoverCell(null, null);
  }

  void _resolveTap(Offset worldPosition) {
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
