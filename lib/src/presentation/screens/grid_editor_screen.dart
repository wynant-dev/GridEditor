import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../application/editor_controller.dart';
import '../../domain/layout/placed_item.dart';
import '../../infrastructure/catalog/catalog_loader.dart';
import '../canvas/grid_canvas.dart';
import '../interaction/grid_interaction_state.dart';
import '../panels/debug/debug_admin_panel.dart';
import '../panels/sidebar/floating_catalog_sidebar.dart';
import '../panels/sidebar/sidebar_theme.dart';
import '../viewport/viewport_controller.dart';

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
    this.showDebugPanel = kDebugMode,
  });

  final CatalogLoader catalogLoader;
  final void Function(int row, int col)? onCellTap;
  final void Function(PlacedItem placement)? onPlacementTap;
  final void Function(String error)? onPlaceError;
  final VoidCallback? onSettingsPressed;
  final Color? seedColor;
  final bool showDebugPanel;

  @override
  State<GridEditorScreen> createState() => _GridEditorScreenState();
}

class _GridEditorScreenState extends State<GridEditorScreen> {
  static const double _sidebarInset = 16;
  static const double _debugPanelInset = 16;

  late final EditorController _controller;
  GridInteractionState? _interactionState;
  ViewportController? _viewportController;
  bool _placeErrorConfigured = false;

  @override
  void initState() {
    super.initState();
    _controller = EditorController();
    if (widget.showDebugPanel) {
      _interactionState = GridInteractionState();
      _viewportController = ViewportController();
    }
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
    _interactionState?.dispose();
    _viewportController?.dispose();
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
                  interactionState: _interactionState,
                  viewportController: _viewportController,
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
            if (widget.showDebugPanel)
              Positioned(
                right: _debugPanelInset,
                top: _debugPanelInset,
                bottom: _debugPanelInset,
                child: DebugAdminPanel(
                  controller: _controller,
                  interactionState: _interactionState,
                  viewportController: _viewportController,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
