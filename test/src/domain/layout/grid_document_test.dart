import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

import '../../../helpers/grid_test_helpers.dart';

void main() {
    final catalog = testCatalog(
    id: 'test',
    name: 'Test',
    items: [
      CatalogItem(id: 'house', name: 'House', width: 1, height: 1),
    ],
  );

  test('itemById returns matching item', () {
    const item = Item(
      id: 'p1',
      catalogItemId: 'house',
      originRow: 0,
      originCol: 0,
    );
    const document = GridDocument(
      rows: 2,
      cols: 2,
      items: [item],
    );

    expect(document.itemById('p1'), item);
    expect(document.itemById('missing'), isNull);
  });

  test('EditorEngine itemById delegates to layout', () {
    const item = Item(
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
        items: [item],
      ),
    );

    expect(engine.itemById('p1'), item);
  });

  test('stickerById returns matching sticker', () {
    const sticker = Sticker(
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
        Sticker(
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
