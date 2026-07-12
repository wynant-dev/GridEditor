import 'package:flutter/material.dart';

import '../../application/editor_controller.dart';
import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../interaction/grid_interaction_state.dart';
import 'floor_hover_preview_layer.dart';
import 'grid_renderer.dart';
import 'item_overlay_layer.dart';
import 'item_validity_preview_layer.dart';
import 'sticker_layers.dart';
import 'sticker_preview_layer.dart';

/// Editor scene stack with correct z-order for floor and item tools.
class EditorGridScene extends StatelessWidget {
  const EditorGridScene({
    super.key,
    required this.document,
    required this.catalog,
    required this.metrics,
    required this.controller,
    required this.interactionState,
    this.hiddenItemId,
    this.hiddenStickerId,
  });

  final GridDocument document;
  final Catalog catalog;
  final GridMetrics metrics;
  final EditorController controller;
  final GridInteractionState interactionState;
  final String? hiddenItemId;
  final String? hiddenStickerId;

  @override
  Widget build(BuildContext context) {
    final inFloorMode = controller.selectedCatalogFloorId != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloorLayers(
          document: document,
          catalog: catalog,
          metrics: metrics,
        ),
        _EditorReactive(
          listenables: [interactionState, controller],
          builder: (context) {
            return FloorHoverPreviewLayer(
              interactionState: interactionState,
              selectedCatalogFloorId: controller.selectedCatalogFloorId,
              catalog: catalog,
              metrics: metrics,
            );
          },
        ),
        GridLinesLayer(metrics: metrics),
        ItemLayers(
          document: document,
          catalog: catalog,
          metrics: metrics,
          hiddenItemId: inFloorMode ? null : hiddenItemId,
          ghostOpacity: inFloorMode ? 0.5 : null,
        ),
        if (!inFloorMode)
          _EditorReactive(
            listenables: [interactionState, controller],
            builder: (context) {
              return ItemValidityPreviewLayer(
                interactionState: interactionState,
                selectedCatalogItemId: controller.selectedCatalogItemId,
                catalog: catalog,
                metrics: metrics,
                document: document,
              );
            },
          ),
        _EditorReactive(
          listenables: [interactionState, controller],
          builder: (context) {
            return ItemOverlayLayer(
              interactionState: interactionState,
              selectedCatalogItemId: controller.selectedCatalogItemId,
              catalog: catalog,
              metrics: metrics,
              document: document,
            );
          },
        ),
        StickerLayers(
          document: document,
          catalog: catalog,
          hiddenStickerId: hiddenStickerId,
        ),
        _EditorReactive(
          listenables: [interactionState, controller],
          builder: (context) {
            return StickerPreviewLayer(
              controller: controller,
              interactionState: interactionState,
              catalog: catalog,
              document: document,
            );
          },
        ),
      ],
    );
  }
}

class _EditorReactive extends StatelessWidget {
  const _EditorReactive({
    required this.listenables,
    required this.builder,
  });

  final List<Listenable> listenables;
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) => builder(context),
    );
  }
}
