import 'dart:ui';

/// Pure sticker placement bounds checks (no Flutter widgets).
class StickerBounds {
  const StickerBounds._();

  static const double kDefaultStickerSize = 48.0;

  /// Returns true when a sticker of [size] centered at ([centerX], [centerY])
  /// fits entirely inside the grid extent.
  static bool isCenterInGrid({
    required int rows,
    required int cols,
    required double cellSize,
    required Offset origin,
    required double centerX,
    required double centerY,
    double size = kDefaultStickerSize,
  }) {
    final half = size / 2;
    final gridLeft = origin.dx;
    final gridTop = origin.dy;
    final gridRight = origin.dx + cols * cellSize;
    final gridBottom = origin.dy + rows * cellSize;

    return centerX - half >= gridLeft &&
        centerY - half >= gridTop &&
        centerX + half <= gridRight &&
        centerY + half <= gridBottom;
  }

  /// Clamps [center] so a sticker of [size] stays within the grid extent.
  static Offset clampCenter({
    required int rows,
    required int cols,
    required double cellSize,
    required Offset origin,
    required Offset center,
    double size = kDefaultStickerSize,
  }) {
    final half = size / 2;
    final gridLeft = origin.dx + half;
    final gridTop = origin.dy + half;
    final gridRight = origin.dx + cols * cellSize - half;
    final gridBottom = origin.dy + rows * cellSize - half;

    return Offset(
      center.dx.clamp(gridLeft, gridRight),
      center.dy.clamp(gridTop, gridBottom),
    );
  }
}
