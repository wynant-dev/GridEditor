/// A user-defined item type that can be placed on the grid.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    this.color,
    this.imagePath,
  }) : assert(width > 0),
       assert(height > 0);

  final String id;
  final String name;
  final int width;
  final int height;

  /// Optional display hint, e.g. `#E53935` or `red`.
  final String? color;

  /// Optional image path (asset, file, or URL depending on the host app).
  final String? imagePath;

  CatalogItem copyWith({
    String? id,
    String? name,
    int? width,
    int? height,
    String? color,
    String? imagePath,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'width': width,
    'height': height,
    if (color != null) 'color': color,
    if (imagePath != null) 'imagePath': imagePath,
  };

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      name: json['name'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      color: json['color'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }
}
