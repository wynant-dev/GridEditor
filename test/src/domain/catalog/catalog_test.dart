import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Catalog category schema', () {
    test('parses sandbox.json with nested category items', () async {
      final json = await rootBundle.loadString('assets/catalogs/sandbox.json');
      final catalog = Catalog.fromJson(json);

      expect(catalog.categories, hasLength(4));
      expect(catalog.categories.first.id, 'buildings');
      expect(catalog.categories.first.iconName, 'apartment');
      expect(catalog.categories.first.items, hasLength(3));
      expect(catalog.items, hasLength(12));
      expect(catalog.itemsInCategory('buildings'), hasLength(3));
      expect(catalog.itemsInCategory('commerce'), hasLength(3));
      expect(catalog.itemsInCategory('furniture'), hasLength(3));
      expect(catalog.itemsInCategory('nature'), hasLength(3));
    });

    test('parses ddv.json with nested category items', () async {
      final json = await rootBundle.loadString('assets/catalogs/ddv.json');
      final catalog = Catalog.fromJson(json);

      expect(catalog.categories, hasLength(4));
      expect(catalog.itemsInCategory('buildings'), hasLength(4));
      expect(catalog.itemsInCategory('commerce'), hasLength(4));
      expect(catalog.itemsInCategory('furniture'), hasLength(4));
      expect(catalog.itemsInCategory('nature'), hasLength(4));
    });

    test('serializes categories with nested items', () {
      const catalog = Catalog(
        id: 'test',
        name: 'Test',
        categories: [
          CatalogCategory(
            id: 'buildings',
            name: 'Buildings',
            iconName: 'apartment',
            items: [
              CatalogItem(
                id: 'house',
                name: 'House',
                width: 2,
                height: 2,
              ),
            ],
          ),
        ],
      );

      final restored = Catalog.fromJsonMap(catalog.toJsonMap());

      expect(restored.categories.single.items.single.id, 'house');
      expect(restored.items.single.width, 2);
    });

    test('categoryIdForItem resolves owning category', () {
      const catalog = Catalog(
        id: 'test',
        name: 'Test',
        categories: [
          CatalogCategory(
            id: 'buildings',
            name: 'Buildings',
            iconName: 'apartment',
            items: [
              CatalogItem(
                id: 'house',
                name: 'House',
                width: 2,
                height: 2,
              ),
            ],
          ),
        ],
      );

      expect(catalog.categoryIdForItem('house'), 'buildings');
      expect(catalog.categoryIdForItem('missing'), isNull);
    });

    test('serializes stickers', () {
      const catalog = Catalog(
        id: 'test',
        name: 'Test',
        stickers: [
          CatalogSticker(
            id: 'tree',
            name: 'Tree',
            iconName: 'park',
          ),
        ],
      );

      final restored = Catalog.fromJsonMap(catalog.toJsonMap());

      expect(restored.stickers.single.id, 'tree');
      expect(restored.stickers.single.iconName, 'park');
    });

    test('parses stickers from sandbox.json', () async {
      final json = await rootBundle.loadString('assets/catalogs/sandbox.json');
      final catalog = Catalog.fromJson(json);

      expect(catalog.stickers, hasLength(4));
      expect(catalog.stickerById('tree')?.name, 'Tree');
    });

    test('parses item iconName from sandbox.json', () async {
      final json = await rootBundle.loadString('assets/catalogs/sandbox.json');
      final catalog = Catalog.fromJson(json);

      expect(catalog.itemById('house')?.iconName, 'home');
      expect(catalog.itemById('bank')?.iconName, isNull);
    });

    test('serializes item iconName', () {
      const item = CatalogItem(
        id: 'house',
        name: 'House',
        width: 2,
        height: 2,
        color: '#EF5350',
        iconName: 'home',
      );

      final restored = CatalogItem.fromJson(item.toJson());

      expect(restored.iconName, 'home');
    });
  });
}
