import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/placed_item.dart';
import '../../application/editor_controller.dart';
import '../canvas/grid_canvas.dart';

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
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 280),
                      child: ClipRect(
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
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 280,
                    child: Material(
                      elevation: 2,
                      color: theme.colorScheme.surfaceContainerLow,
                      child: body!,
                    ),
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
