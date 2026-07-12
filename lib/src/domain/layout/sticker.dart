/// A placed sticker referencing a [CatalogSticker].
class Sticker {
  const Sticker({
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

  Sticker copyWith({
    String? id,
    String? catalogStickerId,
    double? x,
    double? y,
  }) {
    return Sticker(
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

  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      id: json['id'] as String,
      catalogStickerId: json['catalogStickerId'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}
