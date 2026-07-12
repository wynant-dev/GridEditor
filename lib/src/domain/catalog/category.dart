import 'item.dart';

/// A grouping of catalog items shown as an icon in the sidebar.
class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.name,
    required this.iconName,
    this.items = const [],
  });

  final String id;
  final String name;

  /// Material Symbols icon name (e.g. `apartment`, `storefront`).
  final String iconName;
  final List<CatalogItem> items;

  CatalogCategory copyWith({
    String? id,
    String? name,
    String? iconName,
    List<CatalogItem>? items,
  }) {
    return CatalogCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconName': iconName,
    if (items.isNotEmpty)
      'items': [for (final item in items) item.toJson()],
  };

  factory CatalogCategory.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return CatalogCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
      items: [
        for (final entry in rawItems)
          CatalogItem.fromJson(entry as Map<String, dynamic>),
      ],
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogCategory &&
        other.id == id &&
        other.name == name &&
        other.iconName == iconName &&
        other.items == items;
  }

  @override
  int get hashCode => Object.hash(id, name, iconName, Object.hashAll(items));
}
