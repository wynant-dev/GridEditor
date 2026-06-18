import 'package:flutter/material.dart';

import 'grid_interaction_controller.dart';

/// Full-size input overlay that routes pointer events through a single handler.
class GridInteractionLayer extends StatelessWidget {
  const GridInteractionLayer({
    super.key,
    required this.controller,
  });

  final GridInteractionController controller;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (_) => controller.handleHoverExit(),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerHover: controller.handlePointerHover,
        onPointerDown: controller.handlePointerDown,
        onPointerMove: controller.handlePointerMove,
        onPointerUp: controller.handlePointerUp,
        onPointerCancel: controller.handlePointerCancel,
        child: const SizedBox.expand(),
      ),
    );
  }
}
