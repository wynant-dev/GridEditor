import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../../application/editor_controller.dart';
import '../canvas/grid_canvas.dart';
import '../panels/sidebar/sidebar_theme.dart';

/// Generic editor shell: renders grid state and forwards user input upward.
class GridEditorScreen extends StatelessWidget {
  const GridEditorScreen({
    super.key,
    required this.document,
    required this.catalog,
    this.controller,
    this.onCellTap,
    this.onPlacementTap,
    this.onPlaceError,
    this.body,
    this.seedColor,
  });

  final GridDocument document;
  final Catalog catalog;
  final EditorController? controller;
  final void Function(int row, int col)? onCellTap;
  final void Function(PlacedItem placement)? onPlacementTap;
  final void Function(String error)? onPlaceError;
  final Widget? body;
  final Color? seedColor;

  static const double _sidebarInset = 16;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor ?? Colors.blueGrey,
      ),
      useMaterial3: true,
    );

    return Theme(
      data: theme,
      child: Scaffold(
        body: body != null
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: TapRegion(
                      groupId: catalogSubmenuTapGroup,
                      child: GridCanvas(
                        document: document,
                        catalog: catalog,
                        controller: controller,
                        onCellTap: onCellTap,
                        onPlacementTap: onPlacementTap,
                        onPlaceError: onPlaceError,
                      ),
                    ),
                  ),
                  Positioned(
                    left: _sidebarInset,
                    top: _sidebarInset,
                    bottom: _sidebarInset,
                    child: body!,
                  ),
                ],
              )
            : GridCanvas(
                document: document,
                catalog: catalog,
                controller: controller,
                onCellTap: onCellTap,
                onPlacementTap: onPlacementTap,
                onPlaceError: onPlaceError,
              ),
      ),
    );
  }
}
