import 'package:flutter/material.dart';

import '../../../application/editor_controller.dart';
import '../../../application/selection_history_entry.dart';
import '../../theme/catalog_color_resolver.dart';
import 'sidebar_symbol_icon.dart';
import 'sidebar_container.dart';
import 'sidebar_history_button.dart';
import 'sidebar_icon_button.dart';
import 'sidebar_logo_header.dart';
import 'sidebar_section.dart';
import 'sidebar_submenu_icon_item.dart';
import 'sidebar_submenu_item.dart';
import 'sidebar_submenu_panel.dart';
import 'sidebar_theme.dart';

const _floorsSubmenuKey = '__floors__';
const _stickersSubmenuKey = '__stickers__';

/// Which submenu is currently open beside the sidebar.
enum SidebarSubmenuKind { category, floors, stickers }

/// Floating pill-shaped catalog sidebar with icon categories and contextual submenu.
class FloatingCatalogSidebar extends StatefulWidget {
  const FloatingCatalogSidebar({
    super.key,
    required this.controller,
    this.onSettingsPressed,
  });

  final EditorController controller;
  final VoidCallback? onSettingsPressed;

  @override
  State<FloatingCatalogSidebar> createState() => _FloatingCatalogSidebarState();
}

class _FloatingCatalogSidebarState extends State<FloatingCatalogSidebar> {
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _floorAnchorKey = GlobalKey();
  final GlobalKey _stickersAnchorKey = GlobalKey();
  final Map<String, GlobalKey> _categoryAnchorKeys = {};

  String? _openSubmenuKey;
  double _submenuTop = 0;
  bool _submenuPositioned = false;

  @override
  void initState() {
    super.initState();
    _ensureCategoryKeys();
  }

  @override
  void didUpdateWidget(covariant FloatingCatalogSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureCategoryKeys();
    if (_openSubmenuKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _alignOpenSubmenu());
    }
  }

  void _ensureCategoryKeys() {
    for (final category in widget.controller.catalog.categories) {
      _categoryAnchorKeys.putIfAbsent(category.id, GlobalKey.new);
    }
  }

  bool get _isSubmenuOpen => _openSubmenuKey != null;

  double get _hitTestWidth => _isSubmenuOpen
      ? SidebarTheme.width +
            SidebarTheme.submenuOffset +
            SidebarTheme.submenuMinWidth
      : SidebarTheme.width;

  void _toggleCategorySubmenu(String categoryId) {
    if (_openSubmenuKey == categoryId) {
      setState(_closeSubmenu);
      return;
    }
    setState(() {
      _openSubmenuKey = categoryId;
      _submenuPositioned = false;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _positionSubmenuAtAnchor(_categoryAnchorKeys[categoryId]!),
    );
  }

  void _toggleFloorsSubmenu() {
    if (_openSubmenuKey == _floorsSubmenuKey) {
      setState(_closeSubmenu);
      return;
    }
    setState(() {
      _openSubmenuKey = _floorsSubmenuKey;
      _submenuPositioned = false;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _positionSubmenuAtAnchor(_floorAnchorKey),
    );
  }

  void _toggleStickersSubmenu() {
    if (_openSubmenuKey == _stickersSubmenuKey) {
      setState(_closeSubmenu);
      return;
    }
    setState(() {
      _openSubmenuKey = _stickersSubmenuKey;
      _submenuPositioned = false;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _positionSubmenuAtAnchor(_stickersAnchorKey),
    );
  }

  void _closeSubmenu() {
    _openSubmenuKey = null;
    _submenuTop = 0;
    _submenuPositioned = false;
  }

  void _alignOpenSubmenu() {
    final key = _openSubmenuKey;
    if (key == null) return;
    if (key == _floorsSubmenuKey) {
      _positionSubmenuAtAnchor(_floorAnchorKey);
      return;
    }
    if (key == _stickersSubmenuKey) {
      _positionSubmenuAtAnchor(_stickersAnchorKey);
      return;
    }
    final anchorKey = _categoryAnchorKeys[key];
    if (anchorKey != null) {
      _positionSubmenuAtAnchor(anchorKey);
    }
  }

  void _positionSubmenuAtAnchor(GlobalKey anchorKey) {
    final top = _measureSubmenuTop(anchorKey);
    if (top == null || !mounted) return;
    setState(() {
      _submenuTop = top;
      _submenuPositioned = true;
    });
  }

  double? _measureSubmenuTop(GlobalKey anchorKey) {
    final anchorContext = anchorKey.currentContext;
    final stackContext = _stackKey.currentContext;
    if (anchorContext == null || stackContext == null) return null;

    final anchorBox = anchorContext.findRenderObject() as RenderBox?;
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (anchorBox == null || stackBox == null || !anchorBox.hasSize) return null;

    return anchorBox.localToGlobal(Offset.zero, ancestor: stackBox).dy - 8;
  }

  bool _isCategorySelected(String categoryId) {
    if (_openSubmenuKey == categoryId) return true;
    final selectedId = widget.controller.selectedCatalogItemId;
    if (selectedId == null) return false;
    return widget.controller.catalog.itemById(selectedId)?.categoryId == categoryId;
  }

  SidebarSubmenuKind? get _openSubmenuKind {
    if (_openSubmenuKey == null) return null;
    if (_openSubmenuKey == _floorsSubmenuKey) return SidebarSubmenuKind.floors;
    if (_openSubmenuKey == _stickersSubmenuKey) {
      return SidebarSubmenuKind.stickers;
    }
    return SidebarSubmenuKind.category;
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: catalogSubmenuTapGroup,
      child: SizedBox(
        width: _hitTestWidth,
        child: Stack(
          key: _stackKey,
          clipBehavior: Clip.none,
          children: [
          SidebarContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SidebarLogoHeader(),
                const SizedBox(height: 8),
                if (widget.controller.catalog.categories.isNotEmpty)
                  SidebarSection(
                    showDivider: true,
                    children: [
                      for (final category in widget.controller.catalog.categories)
                        KeyedSubtree(
                          key: _categoryAnchorKeys[category.id],
                          child: SidebarIconButton(
                            selected: _isCategorySelected(category.id),
                            tooltip: category.name,
                            onPressed: () => _toggleCategorySubmenu(category.id),
                            icon: SidebarSymbolIcon(
                              iconName: category.iconName,
                              selected: _isCategorySelected(category.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                SidebarSection(
                  showDivider: widget.controller.catalog.stickers.isNotEmpty ||
                      widget.controller.selectionHistory.isNotEmpty,
                  children: [
                    KeyedSubtree(
                      key: _floorAnchorKey,
                      child: SidebarIconButton(
                        selected: widget.controller.selectedCatalogFloorId != null,
                        tooltip: 'Floor tool',
                        onPressed: _toggleFloorsSubmenu,
                        icon: SidebarSymbolIcon(
                          iconName: 'palette',
                          selected: widget.controller.selectedCatalogFloorId != null,
                        ),
                      ),
                    ),
                    if (widget.controller.catalog.stickers.isNotEmpty)
                      KeyedSubtree(
                        key: _stickersAnchorKey,
                        child: SidebarIconButton(
                          selected: widget.controller.selectedCatalogStickerId != null,
                          tooltip: 'Stickers',
                          onPressed: _toggleStickersSubmenu,
                          icon: SidebarSymbolIcon(
                            iconName: 'sticker',
                            selected: widget.controller.selectedCatalogStickerId != null,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                if (widget.controller.selectionHistory.isNotEmpty) ...[
                  SidebarSection(
                    showDivider: true,
                    children: _buildHistoryButtons(),
                  ),
                ],
                SidebarSection(
                  children: [
                    SidebarIconButton(
                      tooltip: 'Settings',
                      onPressed: widget.onSettingsPressed ?? () {},
                      icon: const SidebarSymbolIcon(
                        iconName: 'settings',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (_isSubmenuOpen && _submenuPositioned) _buildSubmenu(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHistoryButtons() {
    return [
      for (final entry in widget.controller.selectionHistory)
        SidebarHistoryButton(
          color: _colorForHistoryEntry(entry),
          label: _labelForHistoryEntry(entry),
          onPressed: () => widget.controller.reselectFromHistory(entry),
        ),
    ];
  }

  Color _colorForHistoryEntry(SelectionHistoryEntry entry) {
    switch (entry.kind) {
      case SelectionKind.item:
        final item = widget.controller.catalog.itemById(entry.id);
        return item != null
            ? CatalogColorResolver.fromItem(item)
            : Colors.blueGrey;
      case SelectionKind.floor:
        final floor = widget.controller.catalog.floorById(entry.id);
        return floor != null
            ? CatalogColorResolver.fromFloor(floor)
            : Colors.blueGrey;
      case SelectionKind.sticker:
        return Colors.teal;
    }
  }

  String _labelForHistoryEntry(SelectionHistoryEntry entry) {
    switch (entry.kind) {
      case SelectionKind.item:
        return widget.controller.catalog.itemById(entry.id)?.name ?? entry.id;
      case SelectionKind.floor:
        return widget.controller.catalog.floorById(entry.id)?.name ?? entry.id;
      case SelectionKind.sticker:
        return widget.controller.catalog.stickerById(entry.id)?.name ?? entry.id;
    }
  }

  Widget _buildSubmenu() {
    return Positioned(
      left: SidebarTheme.width + SidebarTheme.submenuOffset,
      top: _submenuTop,
      width: SidebarTheme.submenuMinWidth,
      child: TapRegion(
        groupId: catalogSubmenuTapGroup,
        onTapOutside: (_) => setState(_closeSubmenu),
        child: _buildSubmenuContent(),
      ),
    );
  }

  Widget _buildSubmenuContent() {
    final kind = _openSubmenuKind;
    if (kind == SidebarSubmenuKind.floors) {
      return SidebarSubmenuPanel(
        children: [
          for (final floor in widget.controller.catalog.floors)
            SidebarSubmenuItem(
              color: CatalogColorResolver.fromFloor(floor),
              label: floor.name,
              selected: floor.id == widget.controller.selectedCatalogFloorId,
              onPressed: () => widget.controller.selectCatalogFloor(floor.id),
            ),
        ],
      );
    }

    if (kind == SidebarSubmenuKind.stickers) {
      return SidebarSubmenuPanel(
        children: [
          for (final sticker in widget.controller.catalog.stickers)
            SidebarSubmenuIconItem(
              iconName: sticker.iconName,
              label: sticker.name,
              selected: sticker.id == widget.controller.selectedCatalogStickerId,
              onPressed: () => widget.controller.selectCatalogSticker(sticker.id),
            ),
        ],
      );
    }

    final categoryId = _openSubmenuKey!;
    final items = widget.controller.catalog.itemsInCategory(categoryId);
    return SidebarSubmenuPanel(
      children: [
        for (final item in items)
          SidebarSubmenuItem(
            color: CatalogColorResolver.fromItem(item),
            label: item.name,
            selected: item.id == widget.controller.selectedCatalogItemId,
            onPressed: () => widget.controller.selectCatalogItem(item.id),
          ),
      ],
    );
  }
}
