import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  testWidgets('GridEditorScreen renders grid canvas', (tester) async {
    const catalog = ItemCatalog(id: 'test', name: 'Test');

    await tester.pumpWidget(
      const MaterialApp(
        home: GridEditorScreen(
          document: GridDocument(rows: 2, cols: 2),
          catalog: catalog,
        ),
      ),
    );

    expect(find.byType(GridCanvas), findsOneWidget);
  });
}
