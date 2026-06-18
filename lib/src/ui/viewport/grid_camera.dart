import 'dart:ui';

class GridCamera {
  final Offset offset;
  final double zoom;

  const GridCamera({
    this.offset = Offset.zero,
    this.zoom = 1.0,
  });

  GridCamera copyWith({
    Offset? offset,
    double? zoom,
  }) {
    return GridCamera(
      offset: offset ?? this.offset,
      zoom: zoom ?? this.zoom,
    );
  }

  GridCamera zoomBy(double factor) {
    return copyWith(zoom: (zoom * factor).clamp(0.2, 4.0));
  }

  /// Zooms while keeping [focalPoint] anchored in screen space.
  GridCamera zoomByAt(double factor, Offset focalPoint) {
    final newZoom = (zoom * factor).clamp(0.2, 4.0);
    if (newZoom == zoom) return this;

    final newOffset =
        focalPoint - (focalPoint - offset) * (newZoom / zoom);
    return copyWith(offset: newOffset, zoom: newZoom);
  }

  GridCamera panBy(Offset delta) {
    return copyWith(offset: offset + delta);
  }
}
