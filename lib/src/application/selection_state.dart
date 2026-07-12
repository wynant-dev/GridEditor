class SelectionState {
  const SelectionState({
    this.selectedItemId,
    this.selectedStickerId,
  });

  /// Selected [Item] instance on the grid.
  final String? selectedItemId;

  /// Selected [Sticker] instance on the grid.
  final String? selectedStickerId;

  SelectionState copyWith({
    String? selectedItemId,
    String? selectedStickerId,
    bool clearItem = false,
    bool clearSticker = false,
  }) {
    return SelectionState(
      selectedItemId:
          clearItem ? null : (selectedItemId ?? this.selectedItemId),
      selectedStickerId: clearSticker
          ? null
          : (selectedStickerId ?? this.selectedStickerId),
    );
  }
}
