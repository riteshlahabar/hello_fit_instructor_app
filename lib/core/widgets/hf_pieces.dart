import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// `₹8,400` — Indian grouping, no decimals. Every money label on the trainer
/// screens is whole rupees; the paise live in the Decimal column.
String rupees(double value) {
  final whole = value.round().abs();
  final digits = whole.toString();

  // Indian grouping: last three, then pairs — 12,34,567, not 1,234,567.
  if (digits.length <= 3) return '${value < 0 ? '-' : ''}₹$digits';

  final tail = digits.substring(digits.length - 3);
  var head = digits.substring(0, digits.length - 3);
  final groups = <String>[];

  while (head.length > 2) {
    groups.insert(0, head.substring(head.length - 2));
    head = head.substring(0, head.length - 2);
  }
  if (head.isNotEmpty) groups.insert(0, head);

  return '${value < 0 ? '-' : ''}₹${groups.join(',')},$tail';
}

/// `.status` — the small rounded status pill, tinted by bucket.
///
/// The four tints are the client's own: green for confirmed, orange for
/// pending, grey for completed, red for cancelled.
class HFStatusPill extends StatelessWidget {
  const HFStatusPill({super.key, required this.label, required this.bucket});

  final String label;
  final String bucket;

  static const _tints = <String, (Color, Color)>{
    'confirmed': (Color(0xFFE9F0E5), Color(0xFF58734E)),
    'pending': (Color(0xFFFFF0E8), Color(0xFFA43D2B)),
    'completed': (Color(0xFFEEE8E1), Color(0xFF71665C)),
    'cancelled': (Color(0xFFF8E5DF), Color(0xFFA54D3E)),
  };

  @override
  Widget build(BuildContext context) {
    final (background, ink) = _tints[bucket] ?? _tints['pending']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(HFRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: .3,
        ),
      ),
    );
  }
}

/// `.avatar` — the initials disc. Square-cornered on the later pages and
/// round on the earlier ones, so the radius is a parameter.
class HFAvatar extends StatelessWidget {
  const HFAvatar({
    super.key,
    required this.initials,
    this.size = 37,
    this.radius,
  });

  final String initials;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: HFColors.avatarBg,
        borderRadius: BorderRadius.circular(radius ?? size / 2),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * .3,
          fontWeight: FontWeight.w700,
          color: HFColors.avatarInk,
        ),
      ),
    );
  }
}

