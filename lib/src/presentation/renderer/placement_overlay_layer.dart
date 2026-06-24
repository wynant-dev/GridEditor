import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/placement/placement_rules.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../../application/interaction/drag_session.dart';
import '../interaction/grid_interaction_state.dart';
import '../theme/catalog_color_resolver.dart';
import 'placement_box.dart';

/// Placement ghost overlays rendered above the grid.
class PlacementOverlayLayer extends StatelessWidget {
  const PlacementOverlayLayer({
    super.key,
    required this.interactionState,
    required this.selectedItemId,
    required this.catalog,
    required this.metrics,
    required this.document,
  });

  final GridInteractionState interactionState;
  final String? selectedItemId;
  final Catalog catalog;
  final GridMetrics metrics;
  final GridDocument document;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!interactionState.isDragging)
          _PlacementGhostPreview(
            selectedItemId: selectedItemId,
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
    required this.selectedItemId,
    required this.interactionState,
    required this.catalog,
    required this.document,
    required this.metrics,
  });

  final String? selectedItemId;
  final GridInteractionState interactionState;
  final Catalog catalog;
  final GridDocument document;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final selectedId = selectedItemId;
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

    return PlacementBox(
      itemName: item.name,
      color: CatalogColorResolver.fromItem(item),
      metrics: metrics,
      row: originRow,
      col: originCol,
      width: item.width,
      height: item.height,
      opacity: 0.5,
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
  final Catalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final session = dragSession;
    if (session == null) return const SizedBox.shrink();

    final placement = document.placementById(session.placementId);
    if (placement == null) return const SizedBox.shrink();

    final item = catalog.itemById(placement.catalogItemId);
    if (item == null) return const SizedBox.shrink();

    return PlacementBox(
      itemName: item.name,
      color: CatalogColorResolver.fromItem(item),
      metrics: metrics,
      row: session.currentRow,
      col: session.currentCol,
      width: item.width,
      height: item.height,
      opacity: 0.5,
    );
  }
}
