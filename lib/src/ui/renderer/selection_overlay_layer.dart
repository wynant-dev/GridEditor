import 'package:flutter/material.dart';

import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../geometry/grid_metrics.dart';

/// Renders a selection outline around the currently selected placement.
class SelectionOverlayLayer extends StatelessWidget {
  const SelectionOverlayLayer({
    super.key,
    required this.selectedPlacementId,
    required this.document,
    required this.catalog,
    required this.metrics,
  });

  final String? selectedPlacementId;
  final GridDocument document;
  final ItemCatalog catalog;
  final GridMetrics metrics;

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

    final topLeft = metrics.cellTopLeft(
      placement.originRow,
      placement.originCol,
    );

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: item.width * metrics.cellWidth,
      height: item.height * metrics.cellHeight,
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
    );
  }
}
