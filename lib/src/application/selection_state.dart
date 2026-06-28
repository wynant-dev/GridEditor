class SelectionState {
  const SelectionState({
    this.selectedPlacementId,
    this.selectedStickerId,
  });

  final String? selectedPlacementId;
  final String? selectedStickerId;

  SelectionState copyWith({
    String? selectedPlacementId,
    String? selectedStickerId,
    bool clearPlacement = false,
    bool clearSticker = false,
  }) {
    return SelectionState(
      selectedPlacementId: clearPlacement
          ? null
          : (selectedPlacementId ?? this.selectedPlacementId),
      selectedStickerId: clearSticker
          ? null
          : (selectedStickerId ?? this.selectedStickerId),
    );
  }
}
