import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// `.cta` / `.primary` — the full-width orange action button.
class HFPrimaryButton extends StatelessWidget {
  const HFPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.busy = false,
    this.trailingArrow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool trailingArrow;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;

    return Opacity(
      opacity: enabled ? 1 : .55,
      child: Material(
        color: HFColors.primary,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      trailingArrow ? '$label   →' : label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
