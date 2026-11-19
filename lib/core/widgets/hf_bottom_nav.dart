import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// One tab in [HFBottomNav].
class HFNavItem {
  const HFNavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Bottom tab bar — `nav` in the HTML pack: white, hairline top border,
/// five evenly spread items, 17px glyph over an 8px label.
class HFBottomNav extends StatelessWidget {
  const HFBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<HFNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: HFColors.white,
        border: Border(top: BorderSide(color: HFColors.line)),
      ),
      padding: EdgeInsets.fromLTRB(5, 10, 5, 13 + bottomInset),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavCell(
              item: items[i],
              active: i == currentIndex,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final HFNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? HFColors.primary : HFColors.navIdle;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 48),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                height: 1.2,
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
