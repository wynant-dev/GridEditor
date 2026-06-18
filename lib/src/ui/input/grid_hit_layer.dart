import 'package:flutter/material.dart';

import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../geometry/grid_metrics.dart';

/// Hit targets for grid cells and placements. Does not paint grid content.
class GridHitLayer extends StatelessWidget {
  const GridHitLayer({
    super.key,
    required this.document,
    required this.catalog,
    required this.metrics,
    this.onCellTap,
    this.onPlacementTap,
  });

  final GridDocument document;
  final ItemCatalog catalog;
  final GridMetrics metrics;
  final void Function(int row, int col)? onCellTap;
  final void Function(PlacedItem placement)? onPlacementTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: List.generate(document.rows, (row) {
            return Expanded(
              child: Row(
                children: List.generate(document.cols, (col) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onCellTap?.call(row, col),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
        for (final placement in document.placements)
          _PlacementHitTarget(
            placement: placement,
            catalog: catalog,
            metrics: metrics,
            onTap: () => onPlacementTap?.call(placement),
          ),
      ],
    );
  }
}

class _PlacementHitTarget extends StatelessWidget {
  const _PlacementHitTarget({
    required this.placement,
    required this.catalog,
    required this.metrics,
    this.onTap,
  });

  final PlacedItem placement;
  final ItemCatalog catalog;
  final GridMetrics metrics;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final item = catalog.itemById(placement.catalogItemId);
    if (item == null) return const SizedBox.shrink();

    final topLeft = metrics.cellTopLeft(placement.originRow, placement.originCol);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: item.width * metrics.cellWidth,
      height: item.height * metrics.cellHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
      ),
    );
  }
}
