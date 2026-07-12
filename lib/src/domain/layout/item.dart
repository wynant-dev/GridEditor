/// A placed catalog item referencing a [CatalogItem].
class Item {
  const Item({
    required this.id,
    required this.catalogItemId,
    required this.originRow,
    required this.originCol,
  });

  final String id;
  final String catalogItemId;
  final int originRow;
  final int originCol;

  Map<String, dynamic> toJson() => {
    'id': id,
    'catalogItemId': catalogItemId,
    'originRow': originRow,
    'originCol': originCol,
  };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      catalogItemId: json['catalogItemId'] as String,
      originRow: json['originRow'] as int,
      originCol: json['originCol'] as int,
    );
  }
}
