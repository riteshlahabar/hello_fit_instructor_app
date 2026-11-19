import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// One `.quick button`.
class QuickAction {
  const QuickAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

/// `.quick` — three equal buttons, 8px gutter.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions});

  final List<QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _QuickButton(actions[i])),
          ],
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton(this.action);

  final QuickAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(HFRadius.quick),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
        decoration: BoxDecoration(
          color: HFColors.white,
          border: Border.all(color: HFColors.line),
          borderRadius: BorderRadius.circular(HFRadius.quick),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, size: 22, color: HFColors.ink),
            const SizedBox(height: 5),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: HFColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
