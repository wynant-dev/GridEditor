import 'package:flutter/material.dart';

import '../../domain/catalog/catalog.dart';

class CatalogPanel extends StatelessWidget {
  const CatalogPanel({
    super.key,
    required this.catalog,
    required this.selectedItemId,
    required this.onItemSelected,
  });

  final Catalog catalog;
  final String? selectedItemId;
  final ValueChanged<String> onItemSelected;

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
        ],
      ),
    );
  }
}
