import 'package:flutter/material.dart';

import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../services/placement_rules.dart';
import '../catalog_color_resolver.dart';
import '../geometry/grid_metrics.dart';
import '../input/drag_session.dart';
import '../viewport/grid_interaction_state.dart';

/// Tool overlays rendered above the grid (ghost preview, selection, etc.).
class OverlayLayer extends StatelessWidget {
  const OverlayLayer({
    super.key,
    required this.interactionState,
    required this.catalog,
    required this.metrics,
    required this.document,
  });

  final GridInteractionState interactionState;
  final ItemCatalog catalog;
  final GridMetrics metrics;
  final GridDocument document;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!interactionState.isDragging)
          _PlacementGhostPreview(
            interactionState: interactionState,
            catalog: catalog,
            document: document,
            metrics: metrics,
          ),
        _DragPlacementPreview(
          dragSession: interactionState.dragSession,
          document: document,
          catalog: catalog,
          metrics: metrics,
        ),
      ],
    );
  }
}

class _PlacementGhostPreview extends StatelessWidget {
  const _PlacementGhostPreview({
    required this.interactionState,
    required this.catalog,
    required this.document,
    required this.metrics,
  });

  final GridInteractionState interactionState;
  final ItemCatalog catalog;
  final GridDocument document;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final selectedId = interactionState.selectedItemId;
    final hoverRow = interactionState.hoverRow;
    final hoverCol = interactionState.hoverCol;
    if (selectedId == null || hoverRow == null || hoverCol == null) {
      return const SizedBox.shrink();
    }

    final item = catalog.itemById(selectedId);
    if (item == null) return const SizedBox.shrink();

    final (originRow, originCol) = PlacementRules.originFromCenterAnchor(
      layout: document,
      item: item,
      anchorRow: hoverRow,
      anchorCol: hoverCol,
    );

    return _GhostPlacementBox(
      itemName: item.name,
      color: CatalogColorResolver.fromItem(item),
      metrics: metrics,
      row: originRow,
      col: originCol,
      width: item.width,
      height: item.height,
    );
  }
}

class _DragPlacementPreview extends StatelessWidget {
  const _DragPlacementPreview({
    required this.dragSession,
    required this.document,
    required this.catalog,
    required this.metrics,
  });

  final DragSession? dragSession;
  final GridDocument document;
  final ItemCatalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final session = dragSession;
    if (session == null) return const SizedBox.shrink();

    final placement = document.placementById(session.placementId);
    if (placement == null) return const SizedBox.shrink();

    final item = catalog.itemById(placement.catalogItemId);
    if (item == null) return const SizedBox.shrink();

    return _GhostPlacementBox(
      itemName: item.name,
      color: CatalogColorResolver.fromItem(item),
      metrics: metrics,
      row: session.currentRow,
      col: session.currentCol,
      width: item.width,
      height: item.height,
    );
  }
}

class _GhostPlacementBox extends StatelessWidget {
  const _GhostPlacementBox({
    required this.itemName,
    required this.color,
    required this.metrics,
    required this.row,
    required this.col,
    required this.width,
    required this.height,
  });

  final String itemName;
  final Color color;
  final GridMetrics metrics;
  final int row;
  final int col;
  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
    final topLeft = metrics.cellTopLeft(row, col);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: width * metrics.cellWidth,
      height: height * metrics.cellHeight,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.5,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black26, width: 3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  itemName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
