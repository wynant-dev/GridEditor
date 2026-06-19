import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'grid_editor.dart';
import 'src/ui/panels/catalog_panel.dart';

/// Bundled catalog JSON path. Override at build/run time, e.g.:
/// `flutter run -d chrome --dart-define=CATALOG_ASSET=assets/catalogs/sandbox.json`
const catalogAsset = String.fromEnvironment(
  'CATALOG_ASSET',
  defaultValue: 'assets/catalogs/ddv.json',
);

void main() {
  runApp(const GridEditorApp());
}

class GridEditorApp extends StatefulWidget {
  const GridEditorApp({super.key});

  @override
  State<GridEditorApp> createState() => _GridEditorAppState();
}

class _GridEditorAppState extends State<GridEditorApp> {
  static const _title = 'Grid Editor';

  late final EditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditorController();
    _loadCatalog();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    try {
      final json = await rootBundle.loadString(catalogAsset);
      if (!mounted) return;
      _controller.loadCatalog(ItemCatalog.fromJson(json));
    } catch (_) {
      // Missing or invalid catalog asset — start with an empty catalog.
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller.configurePlaceError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    });

    return MaterialApp(
      title: _title,
      home: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return GridEditorScreen(
            document: _controller.layout,
            catalog: _controller.catalog,
            controller: _controller,
            body: CatalogPanel(
              catalog: _controller.catalog,
              selectedItemId: _controller.selectedItemId,
              onItemSelected: _controller.selectItem,
            ),
          );
        },
      ),
    );
  }
}
