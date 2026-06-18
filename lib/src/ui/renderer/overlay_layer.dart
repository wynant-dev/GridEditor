import 'package:flutter/material.dart';

import '../../domain/catalog/item_catalog.dart';
import '../catalog_color_resolver.dart';
import '../geometry/grid_metrics.dart';
import '../viewport/grid_interaction_state.dart';

/// Tool overlays rendered above the grid (ghost preview, selection, etc.).
class OverlayLayer extends StatelessWidget {
  const OverlayLayer({
    super.key,
    required this.interactionState,
    required this.catalog,
    required this.metrics,
  });

  final GridInteractionState interactionState;
  final ItemCatalog catalog;
  final GridMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _PlacementGhostPreview(
          interactionState: interactionState,
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
    required this.metrics,
  });

  final GridInteractionState interactionState;
  final ItemCatalog catalog;
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

    final color = CatalogColorResolver.fromItem(item);
    final topLeft = metrics.cellTopLeft(hoverRow, hoverCol);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: item.width * metrics.cellWidth,
      height: item.height * metrics.cellHeight,
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
                  item.name,
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
