import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';
import 'package:grid_editor/src/infrastructure/catalog/catalog_loader.dart';
import 'package:grid_editor/src/presentation/panels/sidebar/floating_catalog_sidebar.dart';

class _FakeCatalogLoader implements CatalogLoader {
  @override
  Future<Catalog?> loadCatalog({String? assetPath}) async => null;
}

void main() {
  testWidgets('GridEditorScreen renders grid canvas and catalog sidebar',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GridEditorScreen(catalogLoader: _FakeCatalogLoader()),
      ),
    );
    await tester.pump();

    expect(find.byType(GridCanvas), findsOneWidget);
    expect(find.byType(FloatingCatalogSidebar), findsOneWidget);
  });
}
