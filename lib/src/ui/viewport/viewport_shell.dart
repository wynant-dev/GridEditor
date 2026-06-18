import 'package:flutter/material.dart';

import '../geometry/viewport_transform.dart';
import 'viewport_controller.dart';

/// Routes pointer input and applies the viewport transform. Does not interpret
/// grid coordinates or render grid content.
class ViewportShell extends StatelessWidget {
  const ViewportShell({
    super.key,
    required this.viewportController,
    required this.transform,
    required this.child,
  });

  final ViewportController viewportController;
  final ViewportTransform transform;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: viewportController.handlePointerSignal,
      onPointerDown: viewportController.handlePointerDown,
      onPointerMove: viewportController.handlePointerMove,
      onPointerUp: viewportController.handlePointerUp,
      onPointerCancel: viewportController.handlePointerCancel,
      child: Transform.translate(
        offset: transform.offset,
        child: Transform.scale(
          scale: transform.zoom,
          alignment: Alignment.topLeft,
          child: child,
        ),
      ),
    );
  }
}
