import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/src/infrastructure/catalog/catalog_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AssetCatalogLoader returns catalog from bundled asset', () async {
    const loader = AssetCatalogLoader(defaultAsset: 'assets/catalogs/sandbox.json');
    final catalog = await loader.loadCatalog();

    expect(catalog, isNotNull);
    expect(catalog!.id, 'sandbox');
  });

  test('AssetCatalogLoader returns null when asset is missing', () async {
    const loader = AssetCatalogLoader(defaultAsset: 'assets/catalogs/missing.json');
    final catalog = await loader.loadCatalog();

    expect(catalog, isNull);
  });
}
