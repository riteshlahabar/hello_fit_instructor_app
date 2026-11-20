import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// `.summary` / `.stats` — the row of small count tiles above a list.
class HFCountTiles extends StatelessWidget {
  const HFCountTiles({super.key, required this.tiles});

  final List<(String value, String label)> tiles;

  @override
  Widget build(BuildContext context) {
    // `IntrinsicHeight`, because `stretch` on its own asks the tiles for an
    // infinite height inside a scroll view: the row has no bounded cross axis
    // there, and three tiles must still end level whatever their label wraps
    // to.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, tile) in tiles.indexed) ...[
            if (index > 0) const SizedBox(width: 7),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(9, 9, 9, 10),
                decoration: BoxDecoration(
                  color: HFColors.soft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tile.$1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: HFColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tile.$2,
                      style: const TextStyle(
                        fontSize: 9,
                        color: HFColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// `.filters` — the horizontally scrolling chip row.
class HFFilterChips<T> extends StatelessWidget {
  const HFFilterChips({
    super.key,
    required this.values,
    required this.labelOf,
    required this.selected,
    required this.onSelect,
  });

  final List<T> values;
  final String Function(T) labelOf;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          for (final value in values) ...[
            if (value != values.first) const SizedBox(width: 6),
            _Chip(
              label: labelOf(value),
              active: value == selected,
              onTap: () => onSelect(value),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? HFColors.primary : HFColors.white,
          border: Border.all(color: active ? HFColors.primary : HFColors.line),
          borderRadius: BorderRadius.circular(HFRadius.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : HFColors.muted,
          ),
        ),
      ),
    );
  }
}

/// `.empty` — the dashed "nothing here" panel every list page carries.
class HFEmptyPanel extends StatelessWidget {
  const HFEmptyPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 26),
      decoration: BoxDecoration(
        color: HFColors.white,
        border: Border.all(color: HFColors.taupe, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, color: HFColors.muted),
      ),
    );
  }
}
