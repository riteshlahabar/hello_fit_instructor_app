import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tokens.dart';

/// The frame pages 07–11 share: back button, logo, four-step progress bar,
/// then an icon tile over the eyebrow / Anton heading / sub copy.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.step,
    required this.icon,
    required this.eyebrow,
    required this.headline,
    required this.headlineAccent,
    required this.sub,
    required this.children,
    this.onBack,
  });

  /// 1-based, out of the four dashes in `.progress`.
  final int step;
  final IconData icon;
  final String eyebrow;
  final String headline;
  final String headlineAccent;
  final String sub;
  final List<Widget> children;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HFColors.ivory,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(onBack: onBack),
              _Progress(step: step),
              const SizedBox(height: 42),
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7E5D8),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, size: 30, color: HFColors.primary),
              ),
              const SizedBox(height: 23),
              Text(
                eyebrow,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: HFColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: '$headline\n',
                  children: [
                    TextSpan(
                      text: headlineAccent,
                      style: AppTheme.display(38, color: HFColors.primary),
                    ),
                  ],
                ),
                style: AppTheme.display(38),
              ),
              const SizedBox(height: 13),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.8,
                  color: Color(0xFF75695E),
                ),
              ),
              const SizedBox(height: 30),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onBack != null)
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HFColors.white,
                border: Border.all(color: const Color(0xFFE8DCCF)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left, size: 22),
            ),
          )
        else
          const SizedBox(width: 36, height: 36),
        Image.asset('assets/images/logo.png', width: 48, height: 48),
      ],
    );
  }
}

/// `.progress` — four 4px dashes, the ones up to `step` in orange.
class _Progress extends StatelessWidget {
  const _Progress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        children: [
          for (var i = 1; i <= 4; i++) ...[
            if (i > 1) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= step ? HFColors.primary : const Color(0xFFE5D9CC),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
