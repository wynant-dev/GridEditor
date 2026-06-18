import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/catalog/item_catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../../services/editor_controller.dart';
import '../geometry/grid_coordinate_mapper.dart';
import '../geometry/grid_metrics.dart';
import '../geometry/viewport_transform.dart';
import '../input/grid_interaction_controller.dart';
import '../input/grid_interaction_layer.dart';
import '../renderer/grid_renderer.dart';
import '../renderer/overlay_layer.dart';
import '../renderer/selection_overlay_layer.dart';
import '../viewport/grid_interaction_state.dart';
import '../viewport/viewport_controller.dart';
import '../viewport/viewport_shell.dart';

bool _supportsHoverPreview() {
  if (kIsWeb) return true;
  switch (defaultTargetPlatform) {
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return true;
    default:
      return false;
  }
}

class GridCanvas extends StatefulWidget {
  const GridCanvas({
    super.key,
    required this.document,
    required this.catalog,
    this.controller,
    this.interactionState,
    this.onCellTap,
    this.onPlacementTap,
    this.onPlaceError,
  });

  final GridDocument document;
  final ItemCatalog catalog;
  final EditorController? controller;
  final GridInteractionState? interactionState;
  final void Function(int row, int col)? onCellTap;
  final void Function(PlacedItem placement)? onPlacementTap;
  final void Function(String error)? onPlaceError;

  @override
  State<GridCanvas> createState() => _GridCanvasState();
}

class _GridCanvasState extends State<GridCanvas> {
  final ViewportController _viewportController = ViewportController();
  late final GridInteractionState _interactionState;
  late final bool _ownsInteractionState;

  @override
  void initState() {
    super.initState();
    _ownsInteractionState = widget.interactionState == null;
    _interactionState = widget.interactionState ?? GridInteractionState();
    widget.controller?.attachInteractionState(_interactionState);
    widget.controller?.configurePlaceError(widget.onPlaceError);
    widget.controller?.addListener(_syncSelectionFromController);
    _interactionState.syncSelectedItemId(widget.controller?.selectedItemId);
  }

  @override
  void didUpdateWidget(GridCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_syncSelectionFromController);
      widget.controller?.attachInteractionState(_interactionState);
      widget.controller?.configurePlaceError(widget.onPlaceError);
      widget.controller?.addListener(_syncSelectionFromController);
      _syncSelectionFromController();
    } else if (oldWidget.onPlaceError != widget.onPlaceError) {
      widget.controller?.configurePlaceError(widget.onPlaceError);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_syncSelectionFromController);
    if (_ownsInteractionState) {
      _interactionState.dispose();
    }
    _viewportController.dispose();
    super.dispose();
  }

  void _syncSelectionFromController() {
    _interactionState.updateSelectedItemId(widget.controller?.selectedItemId);
  }

  Listenable get _contentListenable {
    final sources = <Listenable>[_viewportController];
    final controller = widget.controller;
    if (controller != null) {
      sources.add(controller);
    }
    return Listenable.merge(sources);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListenableBuilder(
          listenable: _contentListenable,
          builder: (context, _) {
            final camera = _viewportController.camera;
            final transform = ViewportTransform(
              offset: camera.offset,
              zoom: camera.zoom,
            );
            final metrics = GridMetrics(
              rows: widget.document.rows,
              cols: widget.document.cols,
              size: Size(constraints.maxWidth, constraints.maxHeight),
              transform: transform,
            );
            final mapper = GridCoordinateMapper(metrics);
            final supportsHover = _supportsHoverPreview();
            final controller = widget.controller;
            final useTools = controller != null;
            final interactionController = GridInteractionController(
              mapper: mapper,
              document: widget.document,
              catalog: widget.catalog,
              interactionState: _interactionState,
              editorController: controller,
              toolManager: useTools ? controller.toolManager : null,
              onCellTap: useTools ? null : widget.onCellTap,
              onPlacementTap: useTools ? null : widget.onPlacementTap,
              supportsHover: supportsHover,
            );

            return ViewportShell(
              viewportController: _viewportController,
              transform: transform,
              child: Stack(
                children: [
                  GridRenderer(
                    document: widget.document,
                    catalog: widget.catalog,
                    metrics: metrics,
                  ),
                  GridInteractionLayer(controller: interactionController),
                  if (controller != null) ...[
                    ListenableBuilder(
                      listenable: _interactionState,
                      builder: (context, _) {
                        return OverlayLayer(
                          interactionState: _interactionState,
                          catalog: widget.catalog,
                          metrics: metrics,
                        );
                      },
                    ),
                    SelectionOverlayLayer(
                      selectedPlacementId: controller.selectedPlacementId,
                      document: widget.document,
                      catalog: widget.catalog,
                      metrics: metrics,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
