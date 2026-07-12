import 'package:flutter/material.dart';

import '../../application/editor_controller.dart';
import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../interaction/grid_interaction_state.dart';
import 'sticker_layers.dart';

/// Semi-transparent sticker ghost while placing or dragging.
class StickerPreviewLayer extends StatelessWidget {
  const StickerPreviewLayer({
    super.key,
    required this.controller,
    required this.interactionState,
    required this.catalog,
    required this.document,
  });

  final EditorController controller;
  final GridInteractionState interactionState;
  final Catalog catalog;
  final GridDocument document;

  static const _ghostOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    final dragSession = interactionState.stickerDragSession;
    if (dragSession != null) {
      final sticker = document.stickerById(dragSession.stickerId);
      if (sticker == null) return const SizedBox.shrink();

      final definition = catalog.stickerById(sticker.catalogStickerId);
      if (definition == null) return const SizedBox.shrink();

      return StickerGlyph(
        iconName: definition.iconName,
        center: dragSession.currentCenter,
        opacity: _ghostOpacity,
      );
    }

    if (interactionState.isDragging) return const SizedBox.shrink();

    final selectedId = controller.selectedCatalogStickerId;
    if (selectedId == null) return const SizedBox.shrink();

    final definition = catalog.stickerById(selectedId);
    if (definition == null) return const SizedBox.shrink();

    final center = interactionState.hoverWorldPosition;
    if (center == null) return const SizedBox.shrink();

    return StickerGlyph(
      iconName: definition.iconName,
      center: center,
      opacity: _ghostOpacity,
    );
  }
}
