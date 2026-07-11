import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/placement/placement_rules.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../interaction/grid_interaction_state.dart';
import 'floor_cell.dart';
import 'placement_preview_target.dart';

/// Per-cell red validity feedback during invalid placement hover or drag move.
class PlacementValidityPreviewLayer extends StatelessWidget {
  const PlacementValidityPreviewLayer({
    super.key,
    required this.interactionState,
    required this.selectedItemId,
    required this.catalog,
    required this.metrics,
    required this.document,
  });

  static const double _validityOpacity = 0.6;

  static final Color _invalidColor =
      Colors.red.shade600.withValues(alpha: _validityOpacity);

  final GridInteractionState interactionState;
  final String? selectedItemId;
  final Catalog catalog;
  final GridMetrics metrics;
  final GridDocument document;

  @override
  Widget build(BuildContext context) {
    final target = PlacementPreviewTarget.resolve(
      interactionState: interactionState,
      selectedItemId: selectedItemId,
      catalog: catalog,
      document: document,
    );
    if (target == null) return const SizedBox.shrink();

    final cells = <Widget>[];

    for (var row = target.originRow; row < target.originRow + target.item.height; row++) {
      for (var col = target.originCol; col < target.originCol + target.item.width; col++) {
        final isValid = PlacementRules.isFootprintCellValid(
          catalog: catalog,
          layout: document,
          item: target.item,
          originRow: target.originRow,
          originCol: target.originCol,
          row: row,
          col: col,
          ignorePlacementId: target.ignorePlacementId,
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
