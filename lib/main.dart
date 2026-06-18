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

  late EditorEngine _engine;
  String? _selectedItemId;

  @override
  void initState() {
    super.initState();
    _engine = EditorEngine(
      catalog: const ItemCatalog(id: 'default', name: 'My catalog'),
      layout: const GridDocument(rows: 12, cols: 12),
    );
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final json = await rootBundle.loadString(catalogAsset);
      final catalog = ItemCatalog.fromJson(json);
      if (!mounted) return;
      setState(() {
        _engine = _engine.copyWith(catalog: catalog);
        _selectedItemId =
            catalog.items.isNotEmpty ? catalog.items.first.id : null;
      });
    } catch (_) {
      // Missing or invalid catalog asset — start with an empty catalog.
    }
  }

  void _onCellTap(int row, int col) {
    final selectedId = _selectedItemId;
    if (selectedId == null) return;

    setState(() {
      try {
        _engine = _engine.placeItem(
          catalogItemId: selectedId,
          originRow: row,
          originCol: col,
        );
      } on StateError catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: GridEditorScreen(
        title: _title,
        document: _engine.layout,
        catalog: _engine.catalog,
        onCellTap: _onCellTap,
        body: CatalogPanel(
          catalog: _engine.catalog,
          selectedItemId: _selectedItemId,
          onItemSelected: (id) => setState(() => _selectedItemId = id),
        ),
      ),
    );
  }
}
