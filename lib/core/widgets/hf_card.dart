import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// `.card` — white panel, hairline border, 16px radius, 13px padding.
class HFCard extends StatelessWidget {
  const HFCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: HFColors.white,
        border: Border.all(color: HFColors.line),
        borderRadius: BorderRadius.circular(HFRadius.card),
      ),
      child: child,
    );
  }
}

/// `.section-head` — title on the left, optional action link on the right.
class HFSectionHead extends StatelessWidget {
  const HFSectionHead({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: HFColors.ink,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: HFColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
