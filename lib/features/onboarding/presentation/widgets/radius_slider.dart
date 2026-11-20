import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// `input[type=range]` with the "1 km — N km radius — 30 km" caption.
class RadiusSlider extends StatelessWidget {
  const RadiusSlider({super.key, required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: value,
          min: 1,
          max: 30,
          divisions: 29,
          activeColor: HFColors.primary,
          inactiveColor: const Color(0xFFE5D9CC),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('1 km', style: TextStyle(fontSize: 10)),
            Text(
              '${value.round()} km radius',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const Text('30 km', style: TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
