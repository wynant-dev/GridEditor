import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/main.dart' as app;
import 'package:grid_editor/src/presentation/panels/sidebar/floating_catalog_sidebar.dart';

void main() {
  testWidgets('shows floating catalog sidebar', (tester) async {
    await tester.pumpWidget(const app.GridEditorApp());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingCatalogSidebar), findsOneWidget);
    expect(find.byTooltip('Floor tool'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
  });
}
