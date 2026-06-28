/// A user-defined sticker type that can be placed freely on the grid.
class CatalogSticker {
  const CatalogSticker({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  final String id;
  final String name;
  final String iconPath;

  CatalogSticker copyWith({
    String? id,
    String? name,
    String? iconPath,
  }) {
    return CatalogSticker(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconPath': iconPath,
  };

  factory CatalogSticker.fromJson(Map<String, dynamic> json) {
    return CatalogSticker(
      id: json['id'] as String,
      name: json['name'] as String,
      iconPath: json['iconPath'] as String,
    );
  }
}
