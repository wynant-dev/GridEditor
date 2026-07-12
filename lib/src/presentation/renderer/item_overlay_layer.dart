import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/rules/item_rules.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../interaction/grid_interaction_state.dart';
import '../theme/catalog_color_resolver.dart';
import 'item_box.dart';
import 'item_preview_target.dart';

/// Item preview overlays rendered above the grid.
class ItemOverlayLayer extends StatelessWidget {
  static const double _invalidOpacity = 0.5;
  const ItemOverlayLayer({
    super.key,
    required this.interactionState,
    required this.selectedCatalogItemId,
    required this.catalog,
    required this.metrics,
    required this.document,
  });

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

    final isValid = ItemRules.itemError(
          catalog: catalog,
          layout: document,
          catalogItemId: target.catalogItem.id,
          originRow: target.originRow,
          originCol: target.originCol,
          ignoreItemId: target.ignoreItemId,
        ) ==
        null;

    return ItemBox(
      itemName: target.catalogItem.name,
      color: CatalogColorResolver.fromItem(target.catalogItem),
      metrics: metrics,
      row: target.originRow,
      col: target.originCol,
      width: target.catalogItem.width,
      height: target.catalogItem.height,
      opacity: isValid ? 1 : _invalidOpacity,
    );
  }
}
