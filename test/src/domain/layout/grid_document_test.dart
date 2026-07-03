import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', categoryId: 'buildings', width: 1, height: 1),
    ],
  );

  test('placementById returns matching placement', () {
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    const document = GridDocument(
      rows: 2,
      cols: 2,
      placements: [placement],
    );

    expect(document.placementById('p1'), placement);
    expect(document.placementById('missing'), isNull);
  });

  test('EditorEngine placementById delegates to layout', () {
    const placement = PlacedItem(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    final engine = EditorEngine(
      catalog: catalog,
      layout: const GridDocument(
        rows: 2,
        cols: 2,
        placements: [placement],
      ),
    );

    expect(engine.placementById('p1'), placement);
  });

  test('stickerById returns matching sticker', () {
    const sticker = PlacedSticker(
      id: 's1',
      catalogStickerId: 'tree',
      x: 24,
      y: 24,
    );
    const document = GridDocument(
      rows: 2,
      cols: 2,
      stickers: [sticker],
    );

    expect(document.stickerById('s1'), sticker);
    expect(document.stickerById('missing'), isNull);
  });

  test('stickers round-trip through JSON', () {
    const document = GridDocument(
      rows: 4,
      cols: 4,
      stickers: [
        PlacedSticker(
          id: 's1',
          catalogStickerId: 'tree',
          x: 48,
          y: 72,
        ),
      ],
    );

    final restored = GridDocument.fromJsonMap(document.toJsonMap());

    expect(restored.stickers.single.x, 48);
    expect(restored.stickers.single.y, 72);
  });
}
