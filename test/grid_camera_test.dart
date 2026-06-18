import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  group('GridCamera', () {
    test('zoomByAt keeps focal point fixed in screen space', () {
      const camera = GridCamera(offset: Offset(100, 50), zoom: 2.0);
      const focalPoint = Offset(200, 150);

      final worldBefore =
          (focalPoint - camera.offset) / camera.zoom;
      final zoomed = camera.zoomByAt(1.5, focalPoint);
      final screenAfter =
          worldBefore * zoomed.zoom + zoomed.offset;

      expect(screenAfter.dx, closeTo(focalPoint.dx, 0.001));
      expect(screenAfter.dy, closeTo(focalPoint.dy, 0.001));
    });
  });
}
