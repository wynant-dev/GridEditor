import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/app.dart';
import 'package:grid_editor/src/infrastructure/catalog/catalog_loader.dart';
import 'package:grid_editor/src/presentation/panels/sidebar/floating_catalog_sidebar.dart';

void main() {
  testWidgets('shows floating catalog sidebar', (tester) async {
    await tester.pumpWidget(
      const GridEditorApp(
        catalogLoader: AssetCatalogLoader(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingCatalogSidebar), findsOneWidget);
    expect(find.byTooltip('Floor tool'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
  });
}
