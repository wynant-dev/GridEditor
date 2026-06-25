import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/grid_editor.dart';

const Size kGridTestViewSize = Size(200, 200);

void setGridTestViewSize(WidgetTester tester, {Size size = kGridTestViewSize}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Offset cellCenter(GridMetrics metrics, int row, int col) {
  return metrics.cellTopLeft(row, col) +
      Offset(metrics.cellWidth / 2, metrics.cellHeight / 2);
}

GridMetrics testMetrics({
  required int rows,
  required int cols,
  Size size = kGridTestViewSize,
}) {
  return GridMetrics(rows: rows, cols: cols, size: size);
}

Offset screenPosition(GridMetrics metrics, int row, int col) {
  return metrics.transform.worldToScreen(cellCenter(metrics, row, col));
}

Future<void> tapGridCell(
  WidgetTester tester, {
  required GridMetrics metrics,
  required int row,
  required int col,
}) async {
  final layerBox = tester.renderObject<RenderBox>(
    find.byType(GridInteractionLayer),
  );
  final position = layerBox.localToGlobal(screenPosition(metrics, row, col));
  final pointer = TestPointer(1);
  await tester.sendEventToBinding(pointer.hover(position));
  await tester.sendEventToBinding(pointer.down(position));
  await tester.sendEventToBinding(pointer.up());
}

Future<void> dragBetweenCells(
  WidgetTester tester, {
  required GridMetrics metrics,
  required int fromRow,
  required int fromCol,
  required int toRow,
  required int toCol,
}) async {
  final layerBox = tester.renderObject<RenderBox>(
    find.byType(GridInteractionLayer),
  );
  final from = layerBox.localToGlobal(
    screenPosition(metrics, fromRow, fromCol),
  );
  final to = layerBox.localToGlobal(screenPosition(metrics, toRow, toCol));
  final pointer = TestPointer(2);
  await tester.sendEventToBinding(pointer.down(from));
  await tester.sendEventToBinding(pointer.move(to));
  await tester.sendEventToBinding(pointer.up());
}
