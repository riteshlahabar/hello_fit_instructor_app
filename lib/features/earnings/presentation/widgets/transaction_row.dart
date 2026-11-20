import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_pieces.dart';
import '../../domain/earnings_models.dart';

/// `.txn` — one line of page 57's "Recent transactions".
///
/// Earnings come in and payouts go out, so the sign and the arrow follow
/// `direction` rather than the row's table.
class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.transaction});

  final EarningsTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final incoming = transaction.incoming;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: HFColors.white,
        border: Border.all(color: HFColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: incoming ? const Color(0xFFE9F0E5) : HFColors.soft,
              borderRadius: BorderRadius.circular(HFRadius.symbol),
            ),
            child: Icon(
              incoming ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 14,
              color: incoming ? const Color(0xFF39835E) : HFColors.muted,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: HFColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${transaction.on} · ${_status(transaction.status)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: HFColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${incoming ? '+' : '−'} ${rupees(transaction.amount)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: incoming ? const Color(0xFF39835E) : HFColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  /// `PAYABLE` → `Payable`. The status words come straight off the enum, and
  /// the design sets them in sentence case.
  static String _status(String value) {
    if (value.isEmpty) return value;
    final words = value.toLowerCase().replaceAll('_', ' ');

    return words[0].toUpperCase() + words.substring(1);
  }
}
