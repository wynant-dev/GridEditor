import 'package:flutter/material.dart';

import 'app.dart';
import 'setup_dependencies.dart';
import 'src/infrastructure/catalog/catalog_loader.dart';

void main() {
  setupDependencies();
  runApp(GridEditorApp(catalogLoader: getIt<CatalogLoader>()));
}
