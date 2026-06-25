import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';
import '../theme/catalog_color_resolver.dart';

class CatalogPanel extends StatelessWidget {
  const CatalogPanel({
    super.key,
    required this.catalog,
    required this.selectedItemId,
    required this.selectedFloorId,
    required this.onItemSelected,
    required this.onFloorSelected,
  });

  final Catalog catalog;
  final String? selectedItemId;
  final String? selectedFloorId;
  final ValueChanged<String> onItemSelected;
  final ValueChanged<String> onFloorSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Catalog', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(catalog.name, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          Text('Items', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (catalog.items.isEmpty)
            const Text('No items yet. Create items or load a catalog.')
          else
            for (final item in catalog.items)
              ListTile(
                selected: item.id == selectedItemId,
                title: Text(item.name),
                subtitle: Text('${item.width} x ${item.height}'),
                onTap: () => onItemSelected(item.id),
              ),
          const SizedBox(height: 16),
          Text('Floors', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (catalog.floors.isEmpty)
            const Text('No floors defined in this catalog.')
          else
            for (final floor in catalog.floors)
              ListTile(
                selected: floor.id == selectedFloorId,
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: CatalogColorResolver.fromFloor(floor),
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                title: Text(floor.name),
                onTap: () => onFloorSelected(floor.id),
              ),
        ],
      ),
    );
  }
}
