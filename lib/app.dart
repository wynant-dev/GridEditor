import 'package:flutter/material.dart';

import 'src/infrastructure/catalog/catalog_loader.dart';
import 'src/presentation/screens/grid_editor_screen.dart';

class GridEditorApp extends StatelessWidget {
  const GridEditorApp({super.key, required this.catalogLoader});

  final CatalogLoader catalogLoader;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grid Editor',
      home: GridEditorScreen(catalogLoader: catalogLoader),
    );
  }
}
