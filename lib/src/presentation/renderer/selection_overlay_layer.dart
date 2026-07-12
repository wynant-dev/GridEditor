import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../../application/interaction/drag_session.dart';

/// Renders a selection outline around the currently selected item.
class SelectionOverlayLayer extends StatelessWidget {
  const SelectionOverlayLayer({
    super.key,
    required this.selectedItemId,
    required this.document,
    required this.catalog,
    required this.metrics,
    required this.onDelete,
    this.dragSession,
  });

  final String? selectedItemId;
  final GridDocument document;
  final Catalog catalog;
  final GridMetrics metrics;
  final VoidCallback onDelete;
  final DragSession? dragSession;

  @override
  Widget build(BuildContext context) {
    final itemId = selectedItemId;
    if (itemId == null) {
      return const SizedBox.shrink();
    }

    final layoutItem = document.itemById(itemId);
    if (layoutItem == null) {
      return const SizedBox.shrink();
    }

    final catalogItem = catalog.itemById(layoutItem.catalogItemId);
    if (catalogItem == null) {
      return const SizedBox.shrink();
    }

    final session = dragSession;
    final originRow = session != null && session.itemId == itemId
        ? session.currentRow
        : layoutItem.originRow;
    final originCol = session != null && session.itemId == itemId
        ? session.currentCol
        : layoutItem.originCol;

    final topLeft = metrics.cellTopLeft(originRow, originCol);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: catalogItem.width * metrics.cellWidth,
      height: catalogItem.height * metrics.cellHeight,
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
            child: _DeleteItemButton(onPressed: onDelete),
          ),
        ],
      ),
    );
  }
}

class _DeleteItemButton extends StatelessWidget {
  const _DeleteItemButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Listener(
      key: const Key('delete_item_button'),
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
