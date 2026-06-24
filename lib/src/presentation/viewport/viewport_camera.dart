import 'dart:ui';

class ViewportCamera {
  final Offset offset;
  final double zoom;

  const ViewportCamera({
    this.offset = Offset.zero,
    this.zoom = 1.0,
  });

  ViewportCamera copyWith({
    Offset? offset,
    double? zoom,
  }) {
    return ViewportCamera(
      offset: offset ?? this.offset,
      zoom: zoom ?? this.zoom,
    );
  }

  ViewportCamera zoomBy(double factor) {
    return copyWith(zoom: (zoom * factor).clamp(0.2, 4.0));
  }

  /// Zooms while keeping [focalPoint] anchored in screen space.
  ViewportCamera zoomByAt(double factor, Offset focalPoint) {
    final newZoom = (zoom * factor).clamp(0.2, 4.0);
    if (newZoom == zoom) return this;

    final newOffset =
        focalPoint - (focalPoint - offset) * (newZoom / zoom);
    return copyWith(offset: newOffset, zoom: newZoom);
  }

  ViewportCamera panBy(Offset delta) {
    return copyWith(offset: offset + delta);
  }
}
