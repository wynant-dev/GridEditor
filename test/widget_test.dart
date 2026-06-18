import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/main.dart' as app;

void main() {
  testWidgets('shows app title', (tester) async {
    await tester.pumpWidget(const app.GridEditorApp());
    expect(find.text('Grid Editor'), findsOneWidget);
  });
}
