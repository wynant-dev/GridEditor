/// Whether a history entry refers to a catalog item or a floor type.
enum SelectionKind { item, floor }

/// A single entry in the recent selection history (items and floors mixed).
class SelectionHistoryEntry {
  const SelectionHistoryEntry({required this.kind, required this.id});

  final SelectionKind kind;
  final String id;

  @override
  bool operator ==(Object other) {
    return other is SelectionHistoryEntry &&
        other.kind == kind &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(kind, id);
}
