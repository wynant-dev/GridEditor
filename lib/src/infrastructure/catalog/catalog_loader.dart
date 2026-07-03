import 'package:flutter/services.dart';

import '../../domain/catalog/catalog.dart';

/// Loads a [Catalog] from an external source (e.g. bundled assets).
abstract class CatalogLoader {
  Future<Catalog?> loadCatalog({String? assetPath});
}

/// Loads catalog JSON from the Flutter asset bundle.
class AssetCatalogLoader implements CatalogLoader {
  const AssetCatalogLoader({this.defaultAsset = 'assets/catalogs/ddv.json'});

  final String defaultAsset;

  @override
  Future<Catalog?> loadCatalog({String? assetPath}) async {
    try {
      final json = await rootBundle.loadString(assetPath ?? defaultAsset);
      return Catalog.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
