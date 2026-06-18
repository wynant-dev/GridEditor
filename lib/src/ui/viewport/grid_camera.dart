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

  GridCamera panBy(Offset delta) {
    return copyWith(offset: offset + delta);
  }
}
