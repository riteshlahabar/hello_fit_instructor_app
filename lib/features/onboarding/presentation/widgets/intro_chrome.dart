import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// `.topline` — logo with its caption, and Skip.
class IntroTopLine extends StatelessWidget {
  const IntroTopLine({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset('assets/images/logo.png', width: 46, height: 46),
            const SizedBox(width: 9),
            const Text(
              'TRAINER APP',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: Color(0xFF75695E),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onSkip,
          child: const Text(
            'Skip',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF75695E),
            ),
          ),
        ),
      ],
    );
  }
}

/// `.pagination` — the active dot stretches to a 22px bar.
class IntroDots extends StatelessWidget {
  const IntroDots({super.key, required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 23, 0, 19),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == active ? HFColors.primary : const Color(0xFFD9CABC),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      ),
    );
  }
}
