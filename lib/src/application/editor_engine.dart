import 'dart:convert';
import 'dart:ui';

import '../domain/catalog/catalog.dart';
import '../domain/layout/floor.dart';
import '../domain/layout/grid_document.dart';
import '../domain/layout/item.dart';
import '../domain/layout/sticker.dart';
import '../domain/rules/floor_rules.dart';
import '../domain/rules/item_rules.dart';
import '../domain/rules/sticker_rules.dart';

/// Bridge between catalog (what exists) and layout (what is placed).
class EditorEngine {
  const EditorEngine({required this.catalog, required this.layout});

  final Catalog catalog;
  final GridDocument layout;

  EditorEngine copyWith({Catalog? catalog, GridDocument? layout}) {
    return EditorEngine(
      catalog: catalog ?? this.catalog,
      layout: layout ?? this.layout,
    );
  }

  EditorEngine resize({required int rows, required int cols}) {
    return copyWith(
      layout: layout.copyWith(rows: rows, cols: cols),
    );
  }

  String? itemError({
    required String catalogItemId,
    required int originRow,
    required int originCol,
    String? ignoreItemId,
  }) {
    return ItemRules.itemError(
      catalog: catalog,
      layout: layout,
      catalogItemId: catalogItemId,
      originRow: originRow,
      originCol: originCol,
      ignoreItemId: ignoreItemId,
    );
  }

  EditorEngine placeItem({
    required String catalogItemId,
    required int originRow,
    required int originCol,
    String? itemId,
  }) {
    final error = itemError(
      catalogItemId: catalogItemId,
      originRow: originRow,
      originCol: originCol,
    );
    if (error != null) {
      throw StateError(error);
    }

    final item = Item(
      id: itemId ?? _nextItemId(),
      catalogItemId: catalogItemId,
      originRow: originRow,
      originCol: originCol,
    );

    return copyWith(
      layout: layout.copyWith(items: [...layout.items, item]),
    );
  }

  EditorEngine removeItem(String itemId) {
    return copyWith(
      layout: layout.copyWith(
        items: [
          for (final item in layout.items)
            if (item.id != itemId) item,
        ],
      ),
    );
  }

  EditorEngine moveItem({
    required String itemId,
    required int newRow,
    required int newCol,
  }) {
    final existing = itemById(itemId);
    if (existing == null) {
      throw StateError('Item not found');
    }

    final error = itemError(
      catalogItemId: existing.catalogItemId,
      originRow: newRow,
      originCol: newCol,
      ignoreItemId: itemId,
    );
    if (error != null) {
      throw StateError(error);
    }

    final without = removeItem(itemId);
    return without.placeItem(
      catalogItemId: existing.catalogItemId,
      originRow: newRow,
      originCol: newCol,
      itemId: itemId,
    );
  }

  bool occupiesCell({required int row, required int col}) {
    return ItemRules.occupiesCell(
      catalog: catalog,
      layout: layout,
      row: row,
      col: col,
    );
  }

  Item? itemCovering({required int row, required int col}) {
    return ItemRules.itemCovering(
      catalog: catalog,
      layout: layout,
      row: row,
      col: col,
    );
  }

  Item? itemById(String id) => layout.itemById(id);

  Sticker? stickerById(String id) => layout.stickerById(id);

  String? stickerError({
    required String catalogStickerId,
    required double x,
    required double y,
    required double cellSize,
    required Offset origin,
  }) {
    if (catalog.stickerById(catalogStickerId) == null) {
      return 'Unknown sticker: $catalogStickerId';
    }
    if (!StickerRules.isCenterInGrid(
      rows: layout.rows,
      cols: layout.cols,
      cellSize: cellSize,
      origin: origin,
      centerX: x,
      centerY: y,
    )) {
      return 'Sticker is out of bounds';
    }
    return null;
  }

  EditorEngine placeSticker({
    required String catalogStickerId,
    required double x,
    required double y,
    required double cellSize,
    required Offset origin,
    String? stickerId,
  }) {
    final error = stickerError(
      catalogStickerId: catalogStickerId,
      x: x,
      y: y,
      cellSize: cellSize,
      origin: origin,
    );
    if (error != null) {
      throw StateError(error);
    }

    final sticker = Sticker(
      id: stickerId ?? _nextStickerId(),
      catalogStickerId: catalogStickerId,
      x: x,
      y: y,
    );

    return copyWith(
      layout: layout.copyWith(stickers: [...layout.stickers, sticker]),
    );
  }

  EditorEngine removeSticker(String stickerId) {
    return copyWith(
      layout: layout.copyWith(
        stickers: [
          for (final sticker in layout.stickers)
            if (sticker.id != stickerId) sticker,
        ],
      ),
    );
  }

  EditorEngine moveSticker({
    required String stickerId,
    required double x,
    required double y,
    required double cellSize,
    required Offset origin,
  }) {
    final existing = stickerById(stickerId);
    if (existing == null) {
      throw StateError('Sticker not found');
    }

    final error = stickerError(
      catalogStickerId: existing.catalogStickerId,
      x: x,
      y: y,
      cellSize: cellSize,
      origin: origin,
    );
    if (error != null) {
      throw StateError(error);
    }

    return copyWith(
      layout: layout.copyWith(
        stickers: [
          for (final sticker in layout.stickers)
            if (sticker.id == stickerId)
              sticker.copyWith(x: x, y: y)
            else
              sticker,
        ],
      ),
    );
  }

  String? floorIdAt(int row, int col) => layout.floorIdAt(row, col);

  EditorEngine applyFloor({
    required int row,
    required int col,
    required String catalogFloorId,
  }) {
    final error = FloorRules.floorError(
      catalog: catalog,
      layout: layout,
      row: row,
      col: col,
      catalogFloorId: catalogFloorId,
    );
    if (error != null) {
      throw StateError(error);
    }

    final withoutCell = [
      for (final floor in layout.floors)
        if (floor.row != row || floor.col != col) floor,
    ];
    final updatedFloors = catalogFloorId == layout.defaultFloorId
        ? withoutCell
        : [
            ...withoutCell,
            Floor(row: row, col: col, catalogFloorId: catalogFloorId),
          ];

    return copyWith(
      layout: layout.copyWith(floors: updatedFloors),
    );
  }

  String layoutToJson() => jsonEncode(layout.toJsonMap());

  factory EditorEngine.fromLayoutJson({
    required Catalog catalog,
    required String source,
  }) {
    return EditorEngine(
      catalog: catalog,
      layout: GridDocument.fromJsonMap(
        jsonDecode(source) as Map<String, dynamic>,
      ),
    );
  }

  String _nextItemId() {
    var max = 0;
    for (final item in layout.items) {
      final match = RegExp(r'^p(\d+)$').firstMatch(item.id);
      if (match == null) continue;
      final value = int.tryParse(match.group(1)!);
      if (value != null && value > max) {
        max = value;
      }
    }
    return 'p${max + 1}';
  }

  String _nextStickerId() {
    var max = 0;
    for (final sticker in layout.stickers) {
      final match = RegExp(r'^s(\d+)$').firstMatch(sticker.id);
      if (match == null) continue;
      final value = int.tryParse(match.group(1)!);
      if (value != null && value > max) {
        max = value;
      }
    }
    return 's${max + 1}';
  }
}
