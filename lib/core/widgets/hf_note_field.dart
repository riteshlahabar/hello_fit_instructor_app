import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// `Message to client (optional)` — the multi-line note box on pages 33 and
/// 34, and the same control page 32 shows the stored note in.
class HFNoteField extends StatelessWidget {
  const HFNoteField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.lines = 3,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int lines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: HFColors.ink,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: HFColors.white,
            border: Border.all(color: HFColors.line),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            controller: controller,
            enabled: enabled,
            minLines: lines,
            maxLines: lines + 2,
            maxLength: 500,
            style: const TextStyle(
              fontSize: 10,
              height: 1.6,
              color: HFColors.ink,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              counterText: '',
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 10, color: HFColors.muted),
            ),
          ),
        ),
      ],
    );
  }
}

/// `.note` / `.info` — the grey paragraph a decision screen closes on.
class HFFinePrint extends StatelessWidget {
  const HFFinePrint({super.key, required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: HFColors.soft,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: HFColors.muted),
            const SizedBox(width: 7),
          ],
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9,
                height: 1.65,
                color: HFColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
