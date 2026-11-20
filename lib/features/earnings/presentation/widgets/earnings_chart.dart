import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_pieces.dart';
import '../../domain/earnings_models.dart';

/// `.chart` — page 57's monthly bars.
///
/// Drawn with sized `Container`s, exactly as the design's CSS does it: the
/// chart is six values and needs no plotting library, and adding one would be
/// a dependency change for a bar of colour.
class EarningsChart extends StatelessWidget {
  const EarningsChart({super.key, required this.bars, this.height = 120});

  final List<EarningsBar> bars;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }

    final peak = bars.map((bar) => bar.amount).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _Axis(peak: peak, height: height),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (index, bar) in bars.indexed) ...[
                      if (index > 0) const SizedBox(width: 6),
                      Expanded(
                        child: _Bar(
                          // A zero month is still drawn, as a 2px stub, so the
                          // six columns stay evenly spaced.
                          fraction: peak <= 0 ? 0 : bar.amount / peak,
                          height: height,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 44),
          child: Row(
            children: [
              for (final (index, bar) in bars.indexed) ...[
                if (index > 0) const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    bar.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 8, color: HFColors.muted),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The `₹50k / 25k / 0` scale down the left of the chart.
class _Axis extends StatelessWidget {
  const _Axis({required this.peak, required this.height});

  final double peak;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Tick(label: rupees(peak)),
          _Tick(label: rupees(peak / 2)),
          const _Tick(label: '0'),
        ],
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 7, color: HFColors.muted),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction, required this.height});

  final double fraction;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (height * fraction).clamp(2.0, height),
      decoration: const BoxDecoration(
        color: HFColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
    );
  }
}
