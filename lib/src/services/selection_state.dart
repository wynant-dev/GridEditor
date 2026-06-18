class SelectionState {
  const SelectionState({this.selectedPlacementId});

  final String? selectedPlacementId;

  SelectionState copyWith({String? selectedPlacementId}) {
    return SelectionState(
      selectedPlacementId: selectedPlacementId ?? this.selectedPlacementId,
    );
  }
}
