import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  group('StickerBounds', () {
    const origin = Offset.zero;
    const cellSize = 48.0;
    const rows = 4;
    const cols = 4;

    test('accepts center inside grid', () {
      expect(
        StickerBounds.isCenterInGrid(
          rows: rows,
          cols: cols,
          cellSize: cellSize,
          origin: origin,
          centerX: 24,
          centerY: 24,
        ),
        isTrue,
      );
    });

    test('rejects center too close to edge', () {
      expect(
        StickerBounds.isCenterInGrid(
          rows: rows,
          cols: cols,
          cellSize: cellSize,
          origin: origin,
          centerX: 10,
          centerY: 24,
        ),
        isFalse,
      );
    });

    test('clampCenter keeps sticker inside grid', () {
      final clamped = StickerBounds.clampCenter(
        rows: rows,
        cols: cols,
        cellSize: cellSize,
        origin: origin,
        center: const Offset(-10, 200),
      );

      expect(clamped.dx, 24);
      expect(clamped.dy, 168);
    });
  });
}
