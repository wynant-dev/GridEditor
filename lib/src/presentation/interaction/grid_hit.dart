import '../../domain/layout/item.dart';
import '../../domain/layout/sticker.dart';

sealed class GridHit {}

class CellHit extends GridHit {
  CellHit({required this.row, required this.col});

  final int row;
  final int col;
}

class ItemHit extends GridHit {
  ItemHit({
    required this.item,
    required this.row,
    required this.col,
  });

  final Item item;
  final int row;
  final int col;
}

class StickerHit extends GridHit {
  StickerHit({
    required this.sticker,
    required this.row,
    required this.col,
  });

  final Sticker sticker;
  final int row;
  final int col;
}
