/// A sticker instance placed freely on the grid (world-space center coordinates).
class PlacedSticker {
  const PlacedSticker({
    required this.id,
    required this.catalogStickerId,
    required this.x,
    required this.y,
  });

  final String id;
  final String catalogStickerId;

  /// World-space center X (grid coordinates, pre-zoom).
  final double x;

  /// World-space center Y (grid coordinates, pre-zoom).
  final double y;

  PlacedSticker copyWith({
    String? id,
    String? catalogStickerId,
    double? x,
    double? y,
  }) {
    return PlacedSticker(
      id: id ?? this.id,
      catalogStickerId: catalogStickerId ?? this.catalogStickerId,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'catalogStickerId': catalogStickerId,
    'x': x,
    'y': y,
  };

  factory PlacedSticker.fromJson(Map<String, dynamic> json) {
    return PlacedSticker(
      id: json['id'] as String,
      catalogStickerId: json['catalogStickerId'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}
