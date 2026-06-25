import 'package:flutter/material.dart';

import 'sidebar_divider.dart';

/// A vertical group of sidebar controls with an optional trailing divider.
class SidebarSection extends StatelessWidget {
  const SidebarSection({
    super.key,
    required this.children,
    this.showDivider = false,
  });

  final List<Widget> children;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          children[i],
        ],
        if (showDivider) ...[
          const SizedBox(height: 8),
          const SidebarDivider(),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
