import 'package:flutter/material.dart';

import '../../domain/geometry/grid_metrics.dart';

class ItemBox extends StatelessWidget {
  const ItemBox({
    super.key,
    required this.itemName,
    required this.color,
    required this.metrics,
    required this.row,
    required this.col,
    required this.width,
    required this.height,
    this.opacity = 1,
  });

  final String itemName;
  final Color color;
  final GridMetrics metrics;
  final int row;
  final int col;
  final int width;
  final int height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final topLeft = metrics.cellTopLeft(row, col);

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      width: width * metrics.cellWidth,
      height: height * metrics.cellHeight,
      child: IgnorePointer(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final box = Padding(
      padding: const EdgeInsets.all(3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black26, width: 3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            itemName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );

    if (opacity >= 1) return box;
    return Opacity(opacity: opacity, child: box);
  }
}
