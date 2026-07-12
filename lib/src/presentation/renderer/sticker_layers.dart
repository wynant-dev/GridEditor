import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../../domain/layout/grid_document.dart';
import '../../domain/layout/sticker.dart';
import '../../domain/rules/sticker_rules.dart';
import '../theme/catalog_icon_resolver.dart';

/// Renders a sticker icon centered at world coordinates.
class StickerGlyph extends StatelessWidget {
  const StickerGlyph({
    super.key,
    required this.iconName,
    required this.center,
    this.opacity = 1.0,
  });

  final String iconName;
  final Offset center;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    const size = StickerRules.kDefaultStickerSize;
    final half = size / 2;

    return Positioned(
      left: center.dx - half,
      top: center.dy - half,
      width: size,
      height: size,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Icon(
            CatalogIconResolver.resolve(iconName),
            size: size,
          ),
        ),
      ),
    );
  }
}

/// Renders placed stickers on the grid (world-space, not cell-snapped).
class StickerLayers extends StatelessWidget {
  const StickerLayers({
    super.key,
    required this.document,
    required this.catalog,
    this.hiddenStickerId,
    this.opacity = 1.0,
  });

  final GridDocument document;
  final Catalog catalog;
  final String? hiddenStickerId;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final sticker in document.stickers)
          if (sticker.id != hiddenStickerId)
            _StickerWidget(
              sticker: sticker,
              catalog: catalog,
              opacity: opacity,
            ),
      ],
    );
  }
}

class _StickerWidget extends StatelessWidget {
  const _StickerWidget({
    required this.sticker,
    required this.catalog,
    required this.opacity,
  });

  final Sticker sticker;
  final Catalog catalog;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final definition = catalog.stickerById(sticker.catalogStickerId);
    if (definition == null) return const SizedBox.shrink();

    return StickerGlyph(
      iconName: definition.iconName,
      center: Offset(sticker.x, sticker.y),
      opacity: opacity,
    );
  }
}
