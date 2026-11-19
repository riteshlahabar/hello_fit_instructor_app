import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../catalog/domain/service_category.dart';

/// `.specialty` from page 15 — symbol, name over caption, tick when chosen.
///
/// Split out of `specialisation_screen.dart` to keep both under the project's
/// 200-line limit.
class SpecialtyTile extends StatelessWidget {
  const SpecialtyTile({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ServiceCategory category;
  final bool selected;
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
            color: selected ? HFColors.statusBg : Colors.white,
            border: Border.all(
              color: selected ? HFColors.primary : const Color(0xFFE8DCCF),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(category.symbol, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      category.caption,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF75695E),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
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
