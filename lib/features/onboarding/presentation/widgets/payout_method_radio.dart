import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// Page 20's payout choice (client, 19-11-2026): UPI **or** a bank account,
/// never both. Whichever side is picked becomes compulsory and the other is
/// hidden — and cleared on the server, so a switch leaves nothing stale.
class PayoutMethodRadio extends StatelessWidget {
  const PayoutMethodRadio({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// `UPI` or `BANK`.
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: _Option(
              label: 'Bank account',
              caption: 'NEFT to your account',
              selected: value == 'BANK',
              onTap: () => onChanged('BANK'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Option(
              label: 'UPI',
              caption: 'Paid to your UPI ID',
              selected: value == 'UPI',
              onTap: () => onChanged('UPI'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.caption,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String caption;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? HFColors.statusBg : Colors.white,
          border: Border.all(
            color: selected ? HFColors.primary : const Color(0xFFE8DCCF),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: selected ? HFColors.primary : const Color(0xFF9A9087),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: const TextStyle(fontSize: 10, color: Color(0xFF75695E)),
            ),
          ],
        ),
      ),
    );
  }
}
