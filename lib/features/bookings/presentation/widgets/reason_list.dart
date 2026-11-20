import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// `.reason` — page 34's radio list.
///
/// Hand-built rather than `RadioListTile`: the design's row is a bordered card
/// that tints when chosen, and Material's tile brings its own padding,
/// typography and ripple that would have to be undone one property at a time.
class ReasonList extends StatelessWidget {
  const ReasonList({
    super.key,
    required this.reasons,
    required this.selected,
    required this.onSelect,
  });

  final List<String> reasons;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final reason in reasons) ...[
          if (reason != reasons.first) const SizedBox(height: 7),
          _Row(
            label: reason,
            // Only the last one carries a hint, and it is the free-text case.
            hint: reason == reasons.last
                ? 'Share a different reason below'
                : null,
            chosen: reason == selected,
            onTap: () => onSelect(reason),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.hint,
    required this.chosen,
    required this.onTap,
  });

  final String label;
  final String? hint;
  final bool chosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: chosen ? HFColors.statusBg : HFColors.white,
          border: Border.all(
            color: chosen ? HFColors.primary : HFColors.line,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                chosen
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 15,
                color: chosen ? HFColors.primary : HFColors.taupe,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.45,
                      fontWeight: chosen ? FontWeight.w600 : FontWeight.w400,
                      color: HFColors.ink,
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      hint!,
                      style: const TextStyle(
                        fontSize: 9,
                        color: HFColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
