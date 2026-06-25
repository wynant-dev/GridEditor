import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../interaction/grid_interaction_state.dart';
import '../theme/catalog_color_resolver.dart';
import 'floor_cell.dart';
import 'placement_box.dart';

/// Floor-mode editor overlays: ghost placements and floor hover preview.
class FloorOverlayLayer extends StatelessWidget {
  const FloorOverlayLayer({
    super.key,
    required this.interactionState,
    required this.selectedFloorId,
    required this.catalog,
    required this.metrics,
    required this.document,
  });

  final GridInteractionState interactionState;
  final String? selectedFloorId;
  final Catalog catalog;
  final GridMetrics metrics;
  final GridDocument document;

  static const _ghostPlacementOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    if (interactionState.isDragging || selectedFloorId == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final placement in document.placements)
          _GhostPlacement(
            placement: placement,
            catalog: catalog,
            metrics: metrics,
          ),
        _FloorHoverPreview(
          selectedFloorId: selectedFloorId,
          interactionState: interactionState,
          catalog: catalog,
          metrics: metrics,
        ),
      ],
    );
  }
}

class _GhostPlacement extends StatelessWidget {
  const _GhostPlacement({
    required this.placement,
    required this.catalog,
    required this.metrics,
  });

  final PlacedItem placement;
  final Catalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final item = catalog.itemById(placement.catalogItemId);
    if (item == null) return const SizedBox.shrink();

    return PlacementBox(
      itemName: item.name,
      color: CatalogColorResolver.fromItem(item),
      metrics: metrics,
      row: placement.originRow,
      col: placement.originCol,
      width: item.width,
      height: item.height,
      opacity: FloorOverlayLayer._ghostPlacementOpacity,
    );
  }
}

class _FloorHoverPreview extends StatelessWidget {
  const _FloorHoverPreview({
    required this.selectedFloorId,
    required this.interactionState,
    required this.catalog,
    required this.metrics,
  });

  final String? selectedFloorId;
  final GridInteractionState interactionState;
  final Catalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final selectedId = selectedFloorId;
    final hoverRow = interactionState.hoverRow;
    final hoverCol = interactionState.hoverCol;
    if (selectedId == null || hoverRow == null || hoverCol == null) {
      return const SizedBox.shrink();
    }

    final floor = catalog.floorById(selectedId);
    if (floor == null) return const SizedBox.shrink();

    return FloorCell(
      color: CatalogColorResolver.fromFloor(floor),
      metrics: metrics,
      row: hoverRow,
      col: hoverCol,
    );
  }
}
