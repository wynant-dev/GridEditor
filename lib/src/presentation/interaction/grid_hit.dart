import '../../domain/layout/placed_item.dart';
import '../../domain/layout/placed_sticker.dart';

sealed class GridHit {}

class CellHit extends GridHit {
  CellHit({required this.row, required this.col});

  final int row;
  final int col;
}

class PlacementHit extends GridHit {
  PlacementHit({
    required this.placement,
    required this.row,
    required this.col,
  });

  final PlacedItem placement;
  final int row;
  final int col;
}

class StickerHit extends GridHit {
  StickerHit({
    required this.sticker,
    required this.row,
    required this.col,
  });

  final PlacedSticker sticker;
  final int row;
  final int col;
}
