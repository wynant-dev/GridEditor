import 'package:get_it/get_it.dart';

import 'src/infrastructure/catalog/catalog_loader.dart';

final getIt = GetIt.instance;

/// Bundled catalog JSON path. Override at build/run time, e.g.:
/// `flutter run -d chrome --dart-define=CATALOG_ASSET=assets/catalogs/sandbox.json`
const catalogAsset = String.fromEnvironment(
  'CATALOG_ASSET',
  defaultValue: 'assets/catalogs/ddv.json',
);

void setupDependencies() {
  getIt.registerLazySingleton<CatalogLoader>(
    () => AssetCatalogLoader(defaultAsset: catalogAsset),
  );
}
