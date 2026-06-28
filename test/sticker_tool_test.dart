import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

import 'grid_test_helpers.dart';

void main() {
  const stickerCatalog = Catalog(
    id: 'test',
    name: 'Test',
    stickers: [
      CatalogSticker(
        id: 'tree',
        name: 'Tree',
        iconPath: 'assets/icons/nature.png',
      ),
    ],
  );

  test('onWorldTap places sticker and returns true', () {
    final controller = EditorController()..loadCatalog(stickerCatalog);
    controller.selectStickerCatalog('tree');
    final tool = StickerTool();
    final ctx = testToolContext(
      controller,
      worldPosition: const Offset(24, 24),
    );

    expect(tool.onWorldTap(ctx), isTrue);
    expect(controller.layout.stickers, hasLength(1));
  });

  test('onCellHover delegates to onHoverWorld callback', () {
    final controller = EditorController()..loadCatalog(stickerCatalog);
    controller.selectStickerCatalog('tree');
    final interactionState = GridInteractionState();
    final tool = StickerTool();
    final ctx = testToolContext(
      controller,
      worldPosition: const Offset(48, 72),
      onHoverWorld: interactionState.setHoverWorldPosition,
    );

    tool.onCellHover(ctx);

    expect(interactionState.hoverWorldPosition, const Offset(48, 72));
  });
}
