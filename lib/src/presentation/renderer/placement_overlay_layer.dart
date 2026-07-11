import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/placement/placement_rules.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../interaction/grid_interaction_state.dart';
import '../theme/catalog_color_resolver.dart';
import 'placement_box.dart';
import 'placement_preview_target.dart';

/// Placement preview overlays rendered above the grid.
class PlacementOverlayLayer extends StatelessWidget {
  static const double _invalidOpacity = 0.5;
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
    final target = PlacementPreviewTarget.resolve(
      interactionState: interactionState,
      selectedItemId: selectedItemId,
      catalog: catalog,
      document: document,
    );
    if (target == null) return const SizedBox.shrink();

    final isValid = PlacementRules.placementError(
          catalog: catalog,
          layout: document,
          catalogItemId: target.item.id,
          originRow: target.originRow,
          originCol: target.originCol,
          ignorePlacementId: target.ignorePlacementId,
        ) ==
        null;

    return PlacementBox(
      itemName: target.item.name,
      color: CatalogColorResolver.fromItem(target.item),
      metrics: metrics,
      row: target.originRow,
      col: target.originCol,
      width: target.item.width,
      height: target.item.height,
      opacity: isValid ? 1 : _invalidOpacity,
    );
  }
}
