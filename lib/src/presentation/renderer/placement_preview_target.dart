import '../../domain/catalog/catalog.dart';
import '../../domain/catalog/item.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/placement/placement_rules.dart';
import '../interaction/grid_interaction_state.dart';

/// Resolved hover/drag placement preview position for overlay layers.
class PlacementPreviewTarget {
  const PlacementPreviewTarget({
    required this.item,
    required this.originRow,
    required this.originCol,
    this.ignorePlacementId,
  });

  final CatalogItem item;
  final int originRow;
  final int originCol;
  final String? ignorePlacementId;

  static PlacementPreviewTarget? resolve({
    required GridInteractionState interactionState,
    required String? selectedItemId,
    required Catalog catalog,
    required GridDocument document,
  }) {
    final dragSession = interactionState.dragSession;
    if (dragSession != null) {
      final placement = document.placementById(dragSession.placementId);
      if (placement == null) return null;

      final item = catalog.itemById(placement.catalogItemId);
      if (item == null) return null;

      return PlacementPreviewTarget(
        item: item,
        originRow: dragSession.currentRow,
        originCol: dragSession.currentCol,
        ignorePlacementId: dragSession.placementId,
      );
    }

    if (interactionState.isDragging) return null;

    final selectedId = selectedItemId;
    final hoverRow = interactionState.hoverRow;
    final hoverCol = interactionState.hoverCol;
    if (selectedId == null || hoverRow == null || hoverCol == null) {
      return null;
    }

    final item = catalog.itemById(selectedId);
    if (item == null) return null;

    final (originRow, originCol) = PlacementRules.originFromCenterAnchor(
      layout: document,
      item: item,
      anchorRow: hoverRow,
      anchorCol: hoverCol,
    );

    return PlacementPreviewTarget(
      item: item,
      originRow: originRow,
      originCol: originCol,
    );
  }
}
