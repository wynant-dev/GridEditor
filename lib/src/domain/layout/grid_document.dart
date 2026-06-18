import 'placed_item.dart';

/// Immutable grid layout state (pure logic, no Flutter).
class GridDocument {
  const GridDocument({
    required this.rows,
    required this.cols,
    this.placements = const [],
  }) : assert(rows > 0),
       assert(cols > 0);

  final int rows;
  final int cols;
  final List<PlacedItem> placements;

  GridDocument copyWith({
    int? rows,
    int? cols,
    List<PlacedItem>? placements,
  }) {
    return GridDocument(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      placements: placements ?? this.placements,
    );
  }

  Map<String, dynamic> toJsonMap() => {
    'rows': rows,
    'cols': cols,
    'placements': [for (final p in placements) p.toJson()],
  };

  factory GridDocument.fromJsonMap(Map<String, dynamic> json) {
    final rawPlacements = json['placements'] as List<dynamic>? ?? [];
    return GridDocument(
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      placements: [
        for (final entry in rawPlacements)
          PlacedItem.fromJson(entry as Map<String, dynamic>),
      ],
    );
  }
}
