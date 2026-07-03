import 'package:flutter/material.dart';

import '../../application/editor_controller.dart';
import '../../domain/layout/placed_item.dart';
import '../../infrastructure/catalog/catalog_loader.dart';
import '../canvas/grid_canvas.dart';
import '../panels/sidebar/floating_catalog_sidebar.dart';
import '../panels/sidebar/sidebar_theme.dart';

/// Editor shell: grid canvas with floating catalog sidebar.
class GridEditorScreen extends StatefulWidget {
  const GridEditorScreen({
    super.key,
    required this.catalogLoader,
    this.onCellTap,
    this.onPlacementTap,
    this.onPlaceError,
    this.onSettingsPressed,
    this.seedColor,
  });

  final CatalogLoader catalogLoader;
  final void Function(int row, int col)? onCellTap;
  final void Function(PlacedItem placement)? onPlacementTap;
  final void Function(String error)? onPlaceError;
  final VoidCallback? onSettingsPressed;
  final Color? seedColor;

  @override
  State<GridEditorScreen> createState() => _GridEditorScreenState();
}

class _GridEditorScreenState extends State<GridEditorScreen> {
  static const double _sidebarInset = 16;

  late final EditorController _controller;
  bool _placeErrorConfigured = false;

  @override
  void initState() {
    super.initState();
    _controller = EditorController();
    _loadCatalog();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_placeErrorConfigured) {
      _placeErrorConfigured = true;
      _controller.configurePlaceError(_showPlaceError);
    }
  }

  void _showPlaceError(String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    final catalog = await widget.catalogLoader.loadCatalog();
    if (!mounted || catalog == null) return;
    _controller.loadCatalog(catalog);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: widget.seedColor ?? Colors.blueGrey,
      ),
      useMaterial3: true,
    );

    final document = _controller.layout;
    final catalog = _controller.catalog;

    return Theme(
      data: theme,
      child: Scaffold(
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: TapRegion(
                groupId: catalogSubmenuTapGroup,
                child: GridCanvas(
                  document: document,
                  catalog: catalog,
                  controller: _controller,
                  onCellTap: widget.onCellTap,
                  onPlacementTap: widget.onPlacementTap,
                  onPlaceError: widget.onPlaceError,
                ),
              ),
            ),
            Positioned(
              left: _sidebarInset,
              top: _sidebarInset,
              bottom: _sidebarInset,
              child: FloatingCatalogSidebar(
                controller: _controller,
                onSettingsPressed: widget.onSettingsPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
