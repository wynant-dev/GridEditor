import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grid_editor/src/presentation/renderer/item_box.dart';

import '../../../helpers/grid_test_helpers.dart';

void main() {
  Future<Size> pumpItemBox(
    WidgetTester tester, {
    required int width,
    required int height,
  }) async {
    final metrics = testMetrics(rows: 8, cols: 8);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 400,
          height: 400,
          child: Stack(
            children: [
              ItemBox(
                itemName: 'House',
                color: Colors.red,
                iconName: 'home',
                metrics: metrics,
                row: 0,
                col: 0,
                width: width,
                height: height,
              ),
            ],
          ),
        ),
      ),
    );

    return tester.getSize(find.byType(FittedBox));
  }

  testWidgets('icon scales with item footprint', (tester) async {
    final small = await pumpItemBox(tester, width: 2, height: 2);
    final large = await pumpItemBox(tester, width: 4, height: 4);

    expect(large.width, greaterThan(small.width));
    expect(large.height, greaterThan(small.height));
    expect(large.width / small.width, closeTo(2, 0.15));
  });

  testWidgets('non-square icon uses fill to stretch with footprint', (tester) async {
    await pumpItemBox(tester, width: 4, height: 3);

    final fittedBox = tester.widget<FittedBox>(find.byType(FittedBox));
    expect(fittedBox.fit, BoxFit.fill);

    final size = tester.getSize(find.byType(FittedBox));
    expect(size.width / size.height, closeTo(4 / 3, 0.05));
  });
}
