/// A floor painted onto a single grid cell.
class FloorTile {
  const FloorTile({
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

  factory FloorTile.fromJson(Map<String, dynamic> json) {
    return FloorTile(
      row: json['row'] as int,
      col: json['col'] as int,
      catalogFloorId: json['catalogFloorId'] as String,
    );
  }
}
