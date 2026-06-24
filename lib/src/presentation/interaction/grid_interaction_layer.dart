import 'package:flutter/material.dart';

import 'grid_interaction_handler.dart';

/// Full-size input overlay that routes pointer events through a single handler.
class GridInteractionLayer extends StatelessWidget {
  const GridInteractionLayer({
    super.key,
    required this.handler,
  });

  final GridInteractionHandler handler;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (_) => handler.handleHoverExit(),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerHover: handler.handlePointerHover,
        onPointerDown: handler.handlePointerDown,
        onPointerMove: handler.handlePointerMove,
        onPointerUp: handler.handlePointerUp,
        onPointerCancel: handler.handlePointerCancel,
        child: const SizedBox.expand(),
      ),
    );
  }
}
