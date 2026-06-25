/// A floor type that can be painted onto individual grid cells.
class CatalogFloor {
  const CatalogFloor({
    required this.id,
    required this.name,
    required this.color,
  });

  final String id;
  final String name;

  /// Display color, e.g. `#42A5F5`.
  final String color;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
  };

  factory CatalogFloor.fromJson(Map<String, dynamic> json) {
    return CatalogFloor(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
    );
  }
}
