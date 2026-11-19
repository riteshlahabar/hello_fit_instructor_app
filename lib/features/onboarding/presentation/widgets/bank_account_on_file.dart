import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// The "Account on file: ••••6789" strip at the top of page 20. The API never
/// returns the full number, so an existing account can only be shown masked.
class BankAccountOnFile extends StatelessWidget {
  const BankAccountOnFile({super.key, required this.mask});

  final String mask;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: HFColors.soft,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(
          'Account on file: $mask',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
