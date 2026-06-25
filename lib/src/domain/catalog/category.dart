/// A grouping of catalog items shown as an icon in the sidebar.
class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  final String id;
  final String name;

  /// Asset path to the category icon image.
  final String iconPath;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconPath': iconPath,
  };

  factory CatalogCategory.fromJson(Map<String, dynamic> json) {
    return CatalogCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      iconPath: json['iconPath'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogCategory &&
        other.id == id &&
        other.name == name &&
        other.iconPath == iconPath;
  }

  @override
  int get hashCode => Object.hash(id, name, iconPath);
}
