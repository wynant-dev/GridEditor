import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

void main() {
  group('GridInteractionState', () {
    test('setHoverCell updates hover state and notifies listeners', () {
      final interactionState = GridInteractionState();
      var notified = 0;
      interactionState.addListener(() => notified++);

      interactionState.setHoverCell(2, 3);

      expect(interactionState.hoverRow, 2);
      expect(interactionState.hoverCol, 3);
      expect(notified, 1);

      interactionState.setHoverCell(2, 3);
      expect(notified, 1);

      interactionState.setHoverCell(null, null);
      expect(interactionState.hoverRow, isNull);
      expect(interactionState.hoverCol, isNull);
      expect(notified, 2);
    });

    test('updateSelectedItemId updates selection and notifies listeners', () {
      final interactionState = GridInteractionState();
      var notified = 0;
      interactionState.addListener(() => notified++);

      interactionState.updateSelectedItemId('house');

      expect(interactionState.selectedItemId, 'house');
      expect(notified, 1);

      interactionState.updateSelectedItemId('house');
      expect(notified, 1);
    });
  });
}
