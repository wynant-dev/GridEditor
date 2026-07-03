import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';
import 'package:grid_editor/src/presentation/panels/sidebar/floating_catalog_sidebar.dart';
import 'package:grid_editor/src/presentation/panels/sidebar/sidebar_submenu_panel.dart';
import 'package:grid_editor/src/presentation/panels/sidebar/sidebar_theme.dart';

void main() {
  const catalog = Catalog(
    id: 'test',
    name: 'Test',
    categories: [
      CatalogCategory(
        id: 'buildings',
        name: 'Buildings',
        iconPath: 'assets/icons/buildings.png',
      ),
    ],
    items: [
      CatalogItem(
        id: 'house',
        name: 'House',
        categoryId: 'buildings',
        width: 2,
        height: 2,
        color: '#EF5350',
      ),
      CatalogItem(
        id: 'bank',
        name: 'Bank',
        categoryId: 'buildings',
        width: 2,
        height: 2,
        color: '#1E88E5',
      ),
    ],
    floors: [
      CatalogFloor(id: 'sand', name: 'Sand', color: '#FFD54F'),
    ],
  );

  Widget buildSidebar(EditorController controller) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) =>
          FloatingCatalogSidebar(controller: controller),
    );
  }

  EditorController controllerWithCatalog(Catalog catalog) {
    final controller = EditorController();
    controller.loadCatalog(catalog);
    return controller;
  }

  testWidgets('tapping category icon opens submenu with items', (tester) async {
    final controller = controllerWithCatalog(catalog);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: buildSidebar(controller),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Buildings'));
    await tester.pumpAndSettle();

    expect(find.text('House'), findsOneWidget);
    expect(find.text('Bank'), findsOneWidget);

    await tester.tap(find.text('Bank'));
    await tester.pumpAndSettle();

    expect(controller.selectedItemId, 'bank');
    expect(find.text('House'), findsOneWidget);
    expect(find.text('Bank'), findsOneWidget);
  });

  testWidgets('tapping empty area on submenu row selects item', (tester) async {
    final controller = controllerWithCatalog(catalog);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: buildSidebar(controller),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Buildings'));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    final panelRect = tester.getRect(find.byType(SidebarSubmenuPanel));
    final bankRect = tester.getRect(find.text('Bank'));
    await tester.tapAt(Offset(panelRect.right - 8, bankRect.center.dy));
    await tester.pumpAndSettle();

    expect(controller.selectedItemId, 'bank');
  });

  testWidgets('tapping floor tool opens floor submenu', (tester) async {
    final controller = controllerWithCatalog(catalog);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: buildSidebar(controller),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Floor tool'));
    await tester.pumpAndSettle();

    expect(find.text('Sand'), findsOneWidget);

    await tester.tap(find.text('Sand'));
    await tester.pumpAndSettle();

    expect(controller.selectedFloorId, 'sand');
    expect(find.text('Sand'), findsOneWidget);
  });

  testWidgets('tapping grouped canvas area keeps submenu open', (tester) async {
    final controller = controllerWithCatalog(catalog);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: TapRegion(
                  groupId: catalogSubmenuTapGroup,
                  child: const ColoredBox(color: Colors.grey),
                ),
              ),
              Positioned(
                left: 16,
                top: 16,
                bottom: 16,
                child: buildSidebar(controller),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Buildings'));
    await tester.pumpAndSettle();

    expect(find.text('House'), findsOneWidget);

    await tester.tapAt(const Offset(300, 300));
    await tester.pumpAndSettle();

    expect(find.text('House'), findsOneWidget);
    expect(find.text('Bank'), findsOneWidget);
  });

  testWidgets('tapping stickers tool opens submenu with sticker entries',
      (tester) async {
    const catalogWithStickers = Catalog(
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

    final controller = controllerWithCatalog(catalogWithStickers);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: buildSidebar(controller),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Stickers'));
    await tester.pumpAndSettle();

    expect(find.text('Tree'), findsOneWidget);
  });
}
