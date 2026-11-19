import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// `.modes` on page 18 — the training locations a provider offers.
///
/// The HTML lists four; `SessionFormat` on the API has three. "Outdoor /
/// Park" is left out rather than folded into `PROVIDER_LOCATION`, which would
/// put a park in the customer's "At the trainer's location" filter (§5.5).
/// Adding it needs a new enum value and a matching change on the customer
/// surfaces, so it is a client decision, not a silent mapping.
class TrainingModeTiles extends StatelessWidget {
  const TrainingModeTiles({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  static const _modes = [
    ('CUSTOMER_HOME', '🏠', "At Client's Home", 'Travel to the client'),
    ('PROVIDER_LOCATION', '🏋️', 'At My Studio', 'Clients visit your place'),
    ('ONLINE', '💻', 'Online Training', 'Live virtual sessions'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (value, icon, title, caption) in _modes)
          _ModeTile(
            icon: icon,
            title: title,
            caption: caption,
            chosen: selected.contains(value),
            onTap: () => onToggle(value),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 12),
          child: Text(
            'Selected: ${selected.length}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF75695E),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.title,
    required this.caption,
    required this.chosen,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String caption;
  final bool chosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: chosen ? HFColors.statusBg : Colors.white,
            border: Border.all(
              color: chosen ? HFColors.primary : const Color(0xFFE8DCCF),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      caption,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF75695E),
                      ),
                    ),
                  ],
                ),
              ),
              if (chosen)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: HFColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
