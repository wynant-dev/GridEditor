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
    this.onHover,
    this.onHoverExit,
  });

  final ViewportController viewportController;
  final ViewportTransform transform;
  final Widget child;
  final void Function(Offset localPosition)? onHover;
  final VoidCallback? onHoverExit;

  @override
  Widget build(BuildContext context) {
    Widget content = Transform.translate(
      offset: transform.offset,
      child: Transform.scale(
        scale: transform.zoom,
        alignment: Alignment.topLeft,
        child: child,
      ),
    );

    final hover = onHover;
    final hoverExit = onHoverExit;
    if (hover != null && hoverExit != null) {
      content = MouseRegion(
        onHover: (event) => hover(event.localPosition),
        onExit: (_) => hoverExit(),
        child: content,
      );
    }

    return Listener(
      onPointerSignal: viewportController.handlePointerSignal,
      onPointerDown: viewportController.handlePointerDown,
      onPointerMove: viewportController.handlePointerMove,
      onPointerUp: viewportController.handlePointerUp,
      onPointerCancel: viewportController.handlePointerCancel,
      child: content,
    );
  }
}
