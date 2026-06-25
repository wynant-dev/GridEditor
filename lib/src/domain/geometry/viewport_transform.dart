import 'dart:ui';

/// Pure viewport pan/zoom math between screen and world coordinates.
class ViewportTransform {
  const ViewportTransform({
    this.offset = Offset.zero,
    this.zoom = 1.0,
  });

  final Offset offset;
  final double zoom;

  Offset screenToWorld(Offset position) {
    return (position - offset) / zoom;
  }

  Offset worldToScreen(Offset world) {
    return offset + world * zoom;
  }
}
