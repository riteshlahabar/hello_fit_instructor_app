import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// One tappable `.item` in a page-65 group: icon tile, title, sub, chevron.
class ProfileMenuRow {
  const ProfileMenuRow({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
}

/// `.group` — a card holding the rows, hairline between them, none after the
/// last. The section label above it is `.sectionlabel`.
class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({super.key, required this.label, required this.rows});

  final String label;
  final List<ProfileMenuRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 0, 7),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
              color: Color(0xFF6F6258),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: HFColors.white,
            border: Border.all(color: HFColors.line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                _Row(row: rows[i], last: i == rows.length - 1),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row, required this.last});

  final ProfileMenuRow row;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: row.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFEFE5DC))),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HFColors.soft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(row.icon, size: 16, color: HFColors.ink),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    row.sub,
                    style: const TextStyle(fontSize: 9, color: HFColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFA89A8D)),
          ],
        ),
      ),
    );
  }
}
