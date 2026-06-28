import 'dart:ui';

/// Tracks an in-progress sticker drag interaction.
class StickerDragSession {
  StickerDragSession({
    required this.stickerId,
    required this.grabOffset,
    required this.currentCenter,
  });

  final String stickerId;

  /// Pointer world position minus sticker center at drag start.
  final Offset grabOffset;

  Offset currentCenter;
}
