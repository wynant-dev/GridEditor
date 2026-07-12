/// A user-defined sticker type that can be placed freely on the grid.
class CatalogSticker {
  const CatalogSticker({
    required this.id,
    required this.name,
    required this.iconName,
  });

  final String id;
  final String name;
  final String iconName;

  CatalogSticker copyWith({
    String? id,
    String? name,
    String? iconName,
  }) {
    return CatalogSticker(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconName': iconName,
  };

  factory CatalogSticker.fromJson(Map<String, dynamic> json) {
    return CatalogSticker(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
    );
  }
}
