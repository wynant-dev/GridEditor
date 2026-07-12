import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../interaction/grid_interaction_state.dart';
import '../theme/catalog_color_resolver.dart';
import 'floor_cell.dart';

/// Floor hover preview while the floor tool is active.
class FloorHoverPreviewLayer extends StatelessWidget {
  const FloorHoverPreviewLayer({
    super.key,
    required this.interactionState,
    required this.selectedCatalogFloorId,
    required this.catalog,
    required this.metrics,
  });

  final GridInteractionState interactionState;
  final String? selectedCatalogFloorId;
  final Catalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    if (interactionState.isDragging || selectedCatalogFloorId == null) {
      return const SizedBox.shrink();
    }

    final selectedId = selectedCatalogFloorId;
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
