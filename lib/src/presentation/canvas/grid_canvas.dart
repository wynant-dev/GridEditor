import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/item.dart';
import '../../application/editor_controller.dart';
import '../../domain/geometry/grid_coordinate_mapper.dart';
import '../../domain/geometry/grid_metrics.dart';
import '../../domain/geometry/viewport_transform.dart';
import 'supports_hover_preview.dart';
import '../interaction/grid_interaction_handler.dart';
import '../interaction/grid_interaction_layer.dart';
import '../interaction/grid_interaction_state.dart';
import '../renderer/editor_grid_scene.dart';
import '../renderer/grid_renderer.dart';
import '../renderer/selection_overlay_layer.dart';
import '../renderer/sticker_selection_overlay_layer.dart';
import '../viewport/viewport_controller.dart';
import '../viewport/viewport_shell.dart';

class GridCanvas extends StatefulWidget {
  const GridCanvas({
    super.key,
    required this.document,
    required this.catalog,
    this.controller,
    this.interactionState,
    this.viewportController,
    this.onCellTap,
    this.onItemTap,
    this.onPlaceError,
  });

  final GridDocument document;
  final Catalog catalog;
  final EditorController? controller;
  final GridInteractionState? interactionState;
  final ViewportController? viewportController;
  final void Function(int row, int col)? onCellTap;
  final void Function(Item item)? onItemTap;
  final void Function(String error)? onPlaceError;

  @override
  State<GridCanvas> createState() => _GridCanvasState();
}

class _GridCanvasState extends State<GridCanvas> {
  late final ViewportController _viewportController;
  late final GridInteractionState _interactionState;
  late final bool _ownsInteractionState;
  late final bool _ownsViewportController;
  late final GridInteractionHandler _interactionHandler;
  String? _hiddenItemId;
  String? _hiddenStickerId;

  @override
  void initState() {
    super.initState();
    _ownsViewportController = widget.viewportController == null;
    _viewportController = widget.viewportController ?? ViewportController();
    _ownsInteractionState = widget.interactionState == null;
    _interactionState = widget.interactionState ?? GridInteractionState();
    _interactionHandler = GridInteractionHandler(
      mapper: GridCoordinateMapper(
        GridMetrics(
          rows: widget.document.rows,
          cols: widget.document.cols,
          size: Size.zero,
        ),
      ),
      document: widget.document,
      catalog: widget.catalog,
      interactionState: _interactionState,
      supportsHover: supportsHoverPreview(),
    );
    _interactionState.addListener(_syncHiddenFromDrag);
    _syncPlaceErrorCallback();
  }

  void _syncPlaceErrorCallback() {
    final onPlaceError = widget.onPlaceError;
    if (onPlaceError != null) {
      widget.controller?.configurePlaceError(onPlaceError);
    }
  }

  @override
  void didUpdateWidget(GridCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.onPlaceError != widget.onPlaceError) {
      _syncPlaceErrorCallback();
    }
  }

  @override
  void dispose() {
    _interactionState.removeListener(_syncHiddenFromDrag);
    if (_ownsInteractionState) {
      _interactionState.dispose();
    }
    if (_ownsViewportController) {
      _viewportController.dispose();
    }
    super.dispose();
  }

  void _syncHiddenFromDrag() {
    final hiddenItemId = _interactionState.dragSession?.itemId;
    final hiddenStickerId = _interactionState.stickerDragSession?.stickerId;
    if (_hiddenItemId == hiddenItemId &&
        _hiddenStickerId == hiddenStickerId) {
      return;
    }
    setState(() {
      _hiddenItemId = hiddenItemId;
      _hiddenStickerId = hiddenStickerId;
    });
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
            final supportsHover = supportsHoverPreview();
            final controller = widget.controller;
            final useTools = controller != null;
            final document = widget.document;

            _interactionHandler.updateContext(
              mapper: mapper,
              document: document,
              catalog: widget.catalog,
              editorController: controller,
              toolManager: useTools ? controller.toolManager : null,
              onCellTap: useTools ? null : widget.onCellTap,
              onItemTap: useTools ? null : widget.onItemTap,
              supportsHover: supportsHover,
            );

            return ViewportShell(
              viewportController: _viewportController,
              transform: transform,
              scene: controller == null
                  ? GridRenderer(
                      document: document,
                      catalog: widget.catalog,
                      metrics: metrics,
                    )
                  : EditorGridScene(
                      document: document,
                      catalog: widget.catalog,
                      metrics: metrics,
                      controller: controller,
                      interactionState: _interactionState,
                      hiddenItemId: _hiddenItemId,
                      hiddenStickerId: _hiddenStickerId,
                    ),
              input: GridInteractionLayer(handler: _interactionHandler),
              overlay: controller != null
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ListenableBuilder(
                          listenable: _interactionState,
                          builder: (context, _) {
                            return SelectionOverlayLayer(
                              selectedItemId:
                                  controller.selectedItemId,
                              document: document,
                              catalog: widget.catalog,
                              metrics: metrics,
                              dragSession: _interactionState.dragSession,
                              onDelete: () {
                                final layoutItem = controller.selectedItem;
                                if (layoutItem != null) {
                                  controller.removeItem(layoutItem);
                                }
                              },
                            );
                          },
                        ),
                        ListenableBuilder(
                          listenable: _interactionState,
                          builder: (context, _) {
                            return StickerSelectionOverlayLayer(
                              selectedStickerId: controller.selectedStickerId,
                              document: document,
                              catalog: widget.catalog,
                              stickerDragSession:
                                  _interactionState.stickerDragSession,
                              onDelete: () {
                                final sticker = controller.selectedSticker;
                                if (sticker != null) {
                                  controller.removeSticker(sticker);
                                }
                              },
                            );
                          },
                        ),
                      ],
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
