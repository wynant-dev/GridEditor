import 'package:flutter/material.dart';

import '../../../application/editor_controller.dart';
import '../../../application/tools/default_tool.dart';
import '../../../application/tools/editor_tool.dart';
import '../../../application/tools/erase_tool.dart';
import '../../../application/tools/floor_tool.dart';
import '../../../application/tools/place_tool.dart';
import '../../../application/tools/sticker_tool.dart';
import '../../interaction/grid_interaction_state.dart';
import '../../viewport/viewport_controller.dart';

/// Debug-only panel that surfaces live editor state.
class DebugAdminPanel extends StatelessWidget {
  const DebugAdminPanel({
    super.key,
    required this.controller,
    this.interactionState,
    this.viewportController,
  });

  final EditorController controller;
  final GridInteractionState? interactionState;
  final ViewportController? viewportController;

  @override
  Widget build(BuildContext context) {
    final listenables = <Listenable>[controller];
    final interaction = interactionState;
    if (interaction != null) {
      listenables.add(interaction);
    }
    final viewport = viewportController;
    if (viewport != null) {
      listenables.add(viewport);
    }

    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) {
        return Container(
          width: 300,
          decoration: BoxDecoration(
            color: const Color(0xF0101010),
            border: Border.all(color: const Color(0xFF424242)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 12,
                offset: Offset(-4, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFFE0E0E0),
                      height: 1.45,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Section(
                          title: 'Tool',
                          children: [
                            _Row(
                              label: 'active',
                              value: _toolLabel(
                                controller.toolManager.activeTool,
                              ),
                            ),
                            _Row(
                              label: 'default',
                              value: _toolLabel(
                                controller.toolManager.defaultTool,
                              ),
                            ),
                          ],
                        ),
                        _Section(
                          title: 'Catalog selection',
                          children: [
                            _Row(
                              label: 'item',
                              value: controller.selectedItemId,
                            ),
                            _Row(
                              label: 'floor',
                              value: controller.selectedFloorId,
                            ),
                            _Row(
                              label: 'sticker',
                              value: controller.selectedStickerCatalogId,
                            ),
                          ],
                        ),
                        _Section(
                          title: 'Canvas selection',
                          children: [
                            _Row(
                              label: 'placement id',
                              value: controller.selectedPlacementId,
                            ),
                            if (controller.selectedPlacement case final placement?)
                              _Row(
                                label: 'placement',
                                value:
                                    '${placement.catalogItemId} @ '
                                    '(${placement.originRow}, ${placement.originCol})',
                              ),
                            _Row(
                              label: 'sticker id',
                              value: controller.selectedStickerId,
                            ),
                            if (controller.selectedSticker case final sticker?)
                              _Row(
                                label: 'sticker',
                                value:
                                    '${sticker.catalogStickerId} @ '
                                    '(${sticker.x.toStringAsFixed(1)}, '
                                    '${sticker.y.toStringAsFixed(1)})',
                              ),
                          ],
                        ),
                        _Section(
                          title: 'Selection history',
                          children: [
                            if (controller.selectionHistory.isEmpty)
                              const _MutedText('(empty)')
                            else
                              for (final entry in controller.selectionHistory)
                                _Row(
                                  label: entry.kind.name,
                                  value: entry.id,
                                ),
                          ],
                        ),
                        _Section(
                          title: 'Layout',
                          children: [
                            _Row(
                              label: 'grid',
                              value:
                                  '${controller.layout.rows}×${controller.layout.cols}',
                            ),
                            _Row(
                              label: 'default floor',
                              value: controller.layout.defaultFloorId,
                            ),
                            _Row(
                              label: 'placements',
                              value: '${controller.layout.placements.length}',
                            ),
                            _Row(
                              label: 'stickers',
                              value: '${controller.layout.stickers.length}',
                            ),
                            _Row(
                              label: 'floor tiles',
                              value: '${controller.layout.floorTiles.length}',
                            ),
                          ],
                        ),
                        _Section(
                          title: 'Placements',
                          children: [
                            if (controller.layout.placements.isEmpty)
                              const _MutedText('(none)')
                            else
                              for (final placement in controller.layout.placements)
                                _Row(
                                  label: placement.id,
                                  value:
                                      '${placement.catalogItemId} '
                                      '(${placement.originRow}, ${placement.originCol})',
                                ),
                          ],
                        ),
                        _Section(
                          title: 'Stickers',
                          children: [
                            if (controller.layout.stickers.isEmpty)
                              const _MutedText('(none)')
                            else
                              for (final sticker in controller.layout.stickers)
                                _Row(
                                  label: sticker.id,
                                  value:
                                      '${sticker.catalogStickerId} '
                                      '(${sticker.x.toStringAsFixed(1)}, '
                                      '${sticker.y.toStringAsFixed(1)})',
                                ),
                          ],
                        ),
                        if (interaction != null)
                          _Section(
                            title: 'Interaction',
                            children: [
                              _Row(
                                label: 'hover cell',
                                value: interaction.hoverRow == null
                                    ? null
                                    : '(${interaction.hoverRow}, ${interaction.hoverCol})',
                              ),
                              _Row(
                                label: 'hover world',
                                value: interaction.hoverWorldPosition == null
                                    ? null
                                    : '(${interaction.hoverWorldPosition!.dx.toStringAsFixed(1)}, '
                                        '${interaction.hoverWorldPosition!.dy.toStringAsFixed(1)})',
                              ),
                              _Row(
                                label: 'dragging',
                                value: interaction.isDragging ? 'yes' : 'no',
                              ),
                              if (interaction.dragSession case final session?)
                                _Row(
                                  label: 'placement drag',
                                  value:
                                      '${session.placementId} → '
                                      '(${session.currentRow}, ${session.currentCol})',
                                ),
                              if (interaction.stickerDragSession
                                  case final session?)
                                _Row(
                                  label: 'sticker drag',
                                  value:
                                      '${session.stickerId} → '
                                      '(${session.currentCenter.dx.toStringAsFixed(1)}, '
                                      '${session.currentCenter.dy.toStringAsFixed(1)})',
                                ),
                            ],
                          ),
                        if (viewport != null)
                          _Section(
                            title: 'Viewport',
                            children: [
                              _Row(
                                label: 'zoom',
                                value: viewport.camera.zoom.toStringAsFixed(2),
                              ),
                              _Row(
                                label: 'offset',
                                value:
                                    '(${viewport.camera.offset.dx.toStringAsFixed(1)}, '
                                    '${viewport.camera.offset.dy.toStringAsFixed(1)})',
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _toolLabel(EditorTool tool) => switch (tool) {
    PlaceTool() => 'PlaceTool',
    FloorTool() => 'FloorTool',
    StickerTool() => 'StickerTool',
    DefaultTool() => 'DefaultTool',
    EraseTool() => 'EraseTool',
    final tool => tool.runtimeType.toString(),
  };
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF424242))),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF66BB6A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Debug state',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFAFAFA),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFF90CAF9),
            ),
          ),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF9E9E9E)),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: TextStyle(
                color: value == null
                    ? const Color(0xFF616161)
                    : const Color(0xFFE0E0E0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Color(0xFF616161)));
  }
}
