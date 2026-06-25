import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Catalog category schema', () {
    test('parses sandbox.json with categories and categoryId', () async {
      final json = await rootBundle.loadString('assets/catalogs/sandbox.json');
      final catalog = Catalog.fromJson(json);

      expect(catalog.categories, hasLength(4));
      expect(catalog.categories.first.id, 'buildings');
      expect(catalog.categories.first.iconPath, 'assets/icons/buildings.png');
      expect(catalog.items, hasLength(12));
      expect(catalog.items.every((item) => item.categoryId.isNotEmpty), isTrue);
      expect(catalog.itemsInCategory('buildings'), hasLength(3));
      expect(catalog.itemsInCategory('commerce'), hasLength(3));
      expect(catalog.itemsInCategory('furniture'), hasLength(3));
      expect(catalog.itemsInCategory('nature'), hasLength(3));
    });

    test('parses ddv.json with categories and categoryId', () async {
      final json = await rootBundle.loadString('assets/catalogs/ddv.json');
      final catalog = Catalog.fromJson(json);

      expect(catalog.categories, hasLength(4));
      expect(catalog.itemsInCategory('buildings'), hasLength(4));
      expect(catalog.itemsInCategory('commerce'), hasLength(4));
      expect(catalog.itemsInCategory('furniture'), hasLength(4));
      expect(catalog.itemsInCategory('nature'), hasLength(4));
    });

    test('serializes categories and categoryId', () {
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
          ),
        ],
      );

      final restored = Catalog.fromJsonMap(catalog.toJsonMap());

      expect(restored.categories, catalog.categories);
      expect(restored.items.single.categoryId, 'buildings');
    });
  });
}
