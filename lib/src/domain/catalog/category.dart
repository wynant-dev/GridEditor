/// A grouping of catalog items shown as an icon in the sidebar.
class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.name,
    required this.iconName,
  });

  final String id;
  final String name;

  /// Material Symbols icon name (e.g. `apartment`, `storefront`).
  final String iconName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconName': iconName,
  };

  factory CatalogCategory.fromJson(Map<String, dynamic> json) {
    return CatalogCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogCategory &&
        other.id == id &&
        other.name == name &&
        other.iconName == iconName;
  }

  @override
  int get hashCode => Object.hash(id, name, iconName);
}
