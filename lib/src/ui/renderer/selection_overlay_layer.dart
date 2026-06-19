import 'package:flutter/material.dart';

import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../geometry/grid_metrics.dart';
import '../input/drag_session.dart';

/// Renders a selection outline around the currently selected placement.
class SelectionOverlayLayer extends StatelessWidget {
  const SelectionOverlayLayer({
    super.key,
    required this.selectedPlacementId,
    required this.document,
    required this.catalog,
    required this.metrics,
    required this.onDelete,
    this.dragSession,
  });

  final String? selectedPlacementId;
  final GridDocument document;
  final ItemCatalog catalog;
  final GridMetrics metrics;
  final VoidCallback onDelete;
  final DragSession? dragSession;

  @override
  Widget build(BuildContext context) {
    final placementId = selectedPlacementId;
    if (placementId == null) {
      return const SizedBox.shrink();
    }

    final placement = document.placementById(placementId);
    if (placement == null) {
      return const SizedBox.shrink();
    }

    final item = catalog.itemById(placement.catalogItemId);
    if (item == null) {
      return const SizedBox.shrink();
    }

    final session = dragSession;
    final originRow = session != null && session.placementId == placementId
        ? session.currentRow
        : placement.originRow;
    final originCol = session != null && session.placementId == placementId
        ? session.currentCol
        : placement.originCol;

    final topLeft = metrics.cellTopLeft(originRow, originCol);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: item.width * metrics.cellWidth,
      height: item.height * metrics.cellHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: _DeletePlacementButton(onPressed: onDelete),
          ),
        ],
      ),
    );
  }
}

class _DeletePlacementButton extends StatelessWidget {
  const _DeletePlacementButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Listener(
      key: const Key('delete_placement_button'),
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onPressed(),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: colorScheme.error,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onError, width: 1),
        ),
        child: Icon(
          Icons.close,
          size: 14,
          color: colorScheme.onError,
        ),
      ),
    );
  }
}
