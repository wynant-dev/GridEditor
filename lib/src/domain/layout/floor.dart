/// A placed floor cell referencing a [CatalogFloor].
class Floor {
  const Floor({
    required this.row,
    required this.col,
    required this.catalogFloorId,
  });

  final int row;
  final int col;
  final String catalogFloorId;

  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col,
    'catalogFloorId': catalogFloorId,
  };

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      row: json['row'] as int,
      col: json['col'] as int,
      catalogFloorId: json['catalogFloorId'] as String,
    );
  }
}
