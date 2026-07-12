import '../../domain/catalog/catalog.dart';
import '../../domain/catalog/item.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/rules/item_rules.dart';
import '../interaction/grid_interaction_state.dart';

/// Resolved hover/drag item preview position for overlay layers.
class ItemPreviewTarget {
  const ItemPreviewTarget({
    required this.catalogItem,
    required this.originRow,
    required this.originCol,
    this.ignoreItemId,
  });

  final CatalogItem catalogItem;
  final int originRow;
  final int originCol;
  final String? ignoreItemId;

  static ItemPreviewTarget? resolve({
    required GridInteractionState interactionState,
    required String? selectedCatalogItemId,
    required Catalog catalog,
    required GridDocument document,
  }) {
    final dragSession = interactionState.dragSession;
    if (dragSession != null) {
      final layoutItem = document.itemById(dragSession.itemId);
      if (layoutItem == null) return null;

      final catalogItem = catalog.itemById(layoutItem.catalogItemId);
      if (catalogItem == null) return null;

      return ItemPreviewTarget(
        catalogItem: catalogItem,
        originRow: dragSession.currentRow,
        originCol: dragSession.currentCol,
        ignoreItemId: dragSession.itemId,
      );
    }

    if (interactionState.isDragging) return null;

    final selectedId = selectedCatalogItemId;
    final hoverRow = interactionState.hoverRow;
    final hoverCol = interactionState.hoverCol;
    if (selectedId == null || hoverRow == null || hoverCol == null) {
      return null;
    }

    final catalogItem = catalog.itemById(selectedId);
    if (catalogItem == null) return null;

    final (originRow, originCol) = ItemRules.originFromCenterAnchor(
      layout: document,
      catalogItem: catalogItem,
      anchorRow: hoverRow,
      anchorCol: hoverCol,
    );

    return ItemPreviewTarget(
      catalogItem: catalogItem,
      originRow: originRow,
      originCol: originCol,
    );
  }
}
