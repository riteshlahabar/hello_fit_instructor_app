import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// `.fields` — the two-column label/value grid pages 31, 32, 33, 34 and 39
/// all put their session details in.
///
/// A `Column` of `Row`s rather than a `GridView`: the values wrap to two lines
/// on a narrow handset and the rows must grow with them, which a grid's fixed
/// extent will not do.
class HFFieldGrid extends StatelessWidget {
  const HFFieldGrid({
    super.key,
    required this.fields,
    this.background = const Color(0xFFFBF3EA),
    this.padding = const EdgeInsets.all(9),
  });

  /// Label, then value. An odd count leaves the last right-hand cell empty.
  final List<(String label, String value)> fields;
  final Color background;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < fields.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: HFField(pair: fields[i])),
                const SizedBox(width: 8),
                Expanded(
                  child: i + 1 < fields.length
                      ? HFField(pair: fields[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// `.field` — one label above one value.
class HFField extends StatelessWidget {
  const HFField({super.key, required this.pair, this.uppercaseLabel = false});

  final (String label, String value) pair;

  /// Pages 33 and 34 set their labels in small caps; page 31 does not.
  final bool uppercaseLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          uppercaseLabel ? pair.$1.toUpperCase() : pair.$1,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: uppercaseLabel ? .6 : 0,
            fontWeight: uppercaseLabel ? FontWeight.w600 : FontWeight.w400,
            color: HFColors.muted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          pair.$2,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: HFColors.ink,
          ),
        ),
      ],
    );
  }
}
