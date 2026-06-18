import 'package:flutter/material.dart';

import '../domain/catalog/item_catalog.dart';
import '../domain/layout/grid_document.dart';
import '../domain/layout/placed_item.dart';
import '../services/editor_controller.dart';
import '../ui/canvas/grid_canvas.dart';
import '../ui/toolbar/grid_toolbar.dart';

/// Generic editor shell: renders grid state and forwards user input upward.
class GridEditorScreen extends StatelessWidget {
  const GridEditorScreen({
    super.key,
    required this.title,
    required this.document,
    required this.catalog,
    this.controller,
    this.onCellTap,
    this.onPlacementTap,
    this.onPlaceError,
    this.toolbarActions = const [],
    this.body,
    this.seedColor,
  });

  final String title;
  final GridDocument document;
  final ItemCatalog catalog;
  final EditorController? controller;
  final void Function(int row, int col)? onCellTap;
  final void Function(PlacedItem placement)? onPlacementTap;
  final void Function(String error)? onPlaceError;
  final List<Widget> toolbarActions;
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
        appBar: GridToolbar(title: title, actions: toolbarActions),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (body != null)
              SizedBox(
                width: 280,
                child: Material(
                  elevation: 1,
                  child: body!,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
          ],
        ),
      ),
    );
  }
}
