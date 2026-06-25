import 'package:flutter/material.dart';

import '../../domain/geometry/viewport_transform.dart';
import 'viewport_controller.dart';

/// Routes pointer input and applies the viewport transform. Does not interpret
/// grid coordinates or render grid content.
///
/// [scene] is transformed by pan/zoom. [overlay] uses the same transform and is
/// painted above [input]. [input] stays in screen space so hit-testing covers
/// the full viewport regardless of zoom or grid extent.
class ViewportShell extends StatelessWidget {
  const ViewportShell({
    super.key,
    required this.viewportController,
    required this.transform,
    required this.scene,
    this.overlay,
    this.input,
  });

  final ViewportController viewportController;
  final ViewportTransform transform;
  final Widget scene;
  final Widget? overlay;
  final Widget? input;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: viewportController.handlePointerSignal,
      onPointerDown: viewportController.handlePointerDown,
      onPointerMove: viewportController.handlePointerMove,
      onPointerUp: viewportController.handlePointerUp,
      onPointerCancel: viewportController.handlePointerCancel,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          _transform(scene),
          if (input != null) Positioned.fill(child: input!),
          if (overlay != null) _transform(overlay!),
        ],
      ),
    );
  }

  Widget _transform(Widget child) {
    return Transform.translate(
      offset: transform.offset,
      child: Transform.scale(
        scale: transform.zoom,
        alignment: Alignment.topLeft,
        child: child,
      ),
    );
  }
}
