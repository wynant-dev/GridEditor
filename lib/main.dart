import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'grid_editor.dart';
import 'src/presentation/panels/sidebar/floating_catalog_sidebar.dart';

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

  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  late final EditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditorController();
    _controller.configurePlaceError(_showPlaceError);
    _loadCatalog();
  }

  void _showPlaceError(String error) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(error)),
    );
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
      _controller.loadCatalog(Catalog.fromJson(json));
    } catch (_) {
      // Missing or invalid catalog asset — start with an empty catalog.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: _title,
      home: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return GridEditorScreen(
            document: _controller.layout,
            catalog: _controller.catalog,
            controller: _controller,
            body: FloatingCatalogSidebar(
              catalog: _controller.catalog,
              selectedItemId: _controller.selectedItemId,
              selectedFloorId: _controller.selectedFloorId,
              selectionHistory: _controller.selectionHistory,
              onItemSelected: _controller.selectItem,
              onFloorSelected: _controller.selectFloor,
              onHistorySelected: _controller.reselectFromHistory,
              onSettingsPressed: () {},
            ),
          );
        },
      ),
    );
  }
}
