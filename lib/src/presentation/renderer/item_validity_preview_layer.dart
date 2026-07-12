import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/rules/item_rules.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../interaction/grid_interaction_state.dart';
import 'floor_cell.dart';
import 'item_preview_target.dart';

/// Per-cell red validity feedback during invalid item hover or drag move.
class ItemValidityPreviewLayer extends StatelessWidget {
  const ItemValidityPreviewLayer({
    super.key,
    required this.interactionState,
    required this.selectedCatalogItemId,
    required this.catalog,
    required this.metrics,
    required this.document,
  });

  static const double _validityOpacity = 0.6;

  static final Color _invalidColor =
      Colors.red.shade600.withValues(alpha: _validityOpacity);

  final GridInteractionState interactionState;
  final String? selectedCatalogItemId;
  final Catalog catalog;
  final GridMetrics metrics;
  final GridDocument document;

  @override
  Widget build(BuildContext context) {
    final target = ItemPreviewTarget.resolve(
      interactionState: interactionState,
      selectedCatalogItemId: selectedCatalogItemId,
      catalog: catalog,
      document: document,
    );
    if (target == null) return const SizedBox.shrink();

    final cells = <Widget>[];

    for (var row = target.originRow;
        row < target.originRow + target.catalogItem.height;
        row++) {
      for (var col = target.originCol;
          col < target.originCol + target.catalogItem.width;
          col++) {
        final isValid = ItemRules.isFootprintCellValid(
          catalog: catalog,
          layout: document,
          catalogItem: target.catalogItem,
          originRow: target.originRow,
          originCol: target.originCol,
          row: row,
          col: col,
          ignoreItemId: target.ignoreItemId,
        );

        if (!isValid) {
          cells.add(
            FloorCell(
              color: _invalidColor,
              metrics: metrics,
              row: row,
              col: col,
            ),
          );
        }
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: cells,
    );
  }
}
