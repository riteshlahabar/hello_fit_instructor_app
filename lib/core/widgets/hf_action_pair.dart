import 'package:flutter/material.dart';

import '../theme/tokens.dart';


/// `.actions` — the two-button row pages 32, 33 and 34 end on. The left
/// button is the way out, the right one is the commitment.
class HFActionPair extends StatelessWidget {
  const HFActionPair({
    super.key,
    required this.secondaryLabel,
    required this.primaryLabel,
    this.onSecondary,
    this.onPrimary,
    this.busy = false,
    this.danger = false,
  });

  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback? onSecondary;
  final VoidCallback? onPrimary;
  final bool busy;

  /// Page 34's Decline button, which is destructive rather than the default.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Button(
            label: secondaryLabel,
            onTap: busy ? null : onSecondary,
            background: HFColors.soft,
            ink: HFColors.ink,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          flex: 2,
          child: _Button(
            label: primaryLabel,
            onTap: busy ? null : onPrimary,
            background: danger ? const Color(0xFFB84B3C) : HFColors.primary,
            ink: Colors.white,
            busy: busy,
          ),
        ),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.onTap,
    required this.background,
    required this.ink,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Color background;
  final Color ink;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? .55 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 46,
            child: Center(
              child: busy
                  ? SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ink,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
