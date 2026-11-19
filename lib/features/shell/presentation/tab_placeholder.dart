import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

/// Holds a tab slot until that screen is converted from its HTML page.
/// Deliberately bare — no invented layout.
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: HFColors.muted),
      ),
    );
  }
}
