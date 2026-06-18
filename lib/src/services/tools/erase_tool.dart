import '../../domain/layout/placed_item.dart';
import 'grid_tool_context.dart';

class EraseTool {
  void onPlacementTap(GridToolContext ctx, PlacedItem placement) {
    ctx.controller.removePlacement(placement);
  }
}
