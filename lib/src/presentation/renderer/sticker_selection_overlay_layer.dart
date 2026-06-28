import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/sticker/sticker_bounds.dart';
import '../../application/interaction/sticker_drag_session.dart';

/// Renders a selection outline around the currently selected sticker.
class StickerSelectionOverlayLayer extends StatelessWidget {
  const StickerSelectionOverlayLayer({
    super.key,
    required this.selectedStickerId,
    required this.document,
    required this.catalog,
    required this.onDelete,
    this.stickerDragSession,
  });

  final String? selectedStickerId;
  final GridDocument document;
  final Catalog catalog;
  final VoidCallback onDelete;
  final StickerDragSession? stickerDragSession;

  @override
  Widget build(BuildContext context) {
    final stickerId = selectedStickerId;
    if (stickerId == null) {
      return const SizedBox.shrink();
    }

    final sticker = document.stickerById(stickerId);
    if (sticker == null) {
      return const SizedBox.shrink();
    }

    if (catalog.stickerById(sticker.catalogStickerId) == null) {
      return const SizedBox.shrink();
    }

    final session = stickerDragSession;
    final center = session != null && session.stickerId == stickerId
        ? session.currentCenter
        : Offset(sticker.x, sticker.y);

    const size = StickerBounds.kDefaultStickerSize;
    final half = size / 2;

    return Positioned(
      left: center.dx - half,
      top: center.dy - half,
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: _DeleteStickerButton(onPressed: onDelete),
          ),
        ],
      ),
    );
  }
}

class _DeleteStickerButton extends StatelessWidget {
  const _DeleteStickerButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Listener(
      key: const Key('delete_sticker_button'),
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onPressed(),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: colorScheme.error,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onError, width: 1),
        ),
        child: Icon(
          Icons.close,
          size: 14,
          color: colorScheme.onError,
        ),
      ),
    );
  }
}
