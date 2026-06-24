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

    test('drag session start, update, and clear notify listeners', () {
      final interactionState = GridInteractionState();
      var notified = 0;
      interactionState.addListener(() => notified++);

      final session = DragSession(
        placementId: 'p1',
        startRow: 0,
        startCol: 0,
        grabOffsetRow: 0,
        grabOffsetCol: 0,
        currentRow: 0,
        currentCol: 0,
      );
      interactionState.startDragSession(session);
      expect(interactionState.isDragging, isTrue);
      expect(notified, 1);

      interactionState.updateDragPosition(1, 2);
      expect(session.currentRow, 1);
      expect(session.currentCol, 2);
      expect(notified, 2);

      interactionState.updateDragPosition(1, 2);
      expect(notified, 2);

      interactionState.clearDragSession();
      expect(interactionState.isDragging, isFalse);
      expect(notified, 3);
    });
  });
}
