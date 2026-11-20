import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// `.search` — the one search box pages 30, 37 and 38 share.
///
/// Debounced, because every keystroke would otherwise be a request: the
/// filtering is a server-side `where`, which is where it belongs, so the cost
/// of a character is a round-trip.
class HFSearchField extends StatefulWidget {
  const HFSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.debounce = const Duration(milliseconds: 350),
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final Duration debounce;

  @override
  State<HFSearchField> createState() => _HFSearchFieldState();
}

class _HFSearchFieldState extends State<HFSearchField> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(value));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HFColors.white,
        border: Border.all(color: HFColors.line),
        borderRadius: BorderRadius.circular(11),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 16, color: HFColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: _onChanged,
              style: const TextStyle(fontSize: 11, color: HFColors.ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: widget.hint,
                hintStyle: const TextStyle(fontSize: 11, color: HFColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
