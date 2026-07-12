/// Catalog template for placeable items. On the grid this becomes an [Item].
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    this.color,
    this.iconName,
    this.imagePath,
  }) : assert(width > 0),
       assert(height > 0);

  final String id;
  final String name;
  final int width;
  final int height;

  /// Optional display hint, e.g. `#E53935` or `red`.
  final String? color;

  /// When set, the item is drawn as this Material Symbols icon instead of a
  /// colored rectangle (e.g. `home`, `storefront`).
  final String? iconName;

  /// Optional image path (asset, file, or URL depending on the host app).
  final String? imagePath;

  CatalogItem copyWith({
    String? id,
    String? name,
    int? width,
    int? height,
    String? color,
    String? iconName,
    String? imagePath,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'width': width,
    'height': height,
    if (color != null) 'color': color,
    if (iconName != null) 'iconName': iconName,
    if (imagePath != null) 'imagePath': imagePath,
  };

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      name: json['name'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      color: json['color'] as String?,
      iconName: json['iconName'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogItem &&
        other.id == id &&
        other.name == name &&
        other.width == width &&
        other.height == height &&
        other.color == color &&
        other.iconName == iconName &&
        other.imagePath == imagePath;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, width, height, color, iconName, imagePath);
}
