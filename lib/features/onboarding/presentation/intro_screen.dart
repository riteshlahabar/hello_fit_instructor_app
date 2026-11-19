import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/hf_primary_button.dart';
import '../domain/intro_slide.dart';
import 'widgets/intro_art.dart';
import 'widgets/intro_chrome.dart';

/// Pages 02–05 — one carousel, four slides, four pagination dots.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == IntroSlide.all.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _finish() => context.go('/login/mobile');

  @override
  Widget build(BuildContext context) {
    final slides = IntroSlide.all;

    return Scaffold(
      backgroundColor: HFColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 24, 25, 25),
          child: Column(
            children: [
              IntroTopLine(onSkip: _finish),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _Slide(slide: slides[i]),
                ),
              ),
              IntroDots(count: slides.length, active: _index),
              HFPrimaryButton(label: 'GET STARTED', onPressed: _next),
              const SizedBox(height: 13),
              const Text(
                'YOUR TIME, YOUR PLACE',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: .4,
                  color: Color(0xFF9B8E81),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final IntroSlide slide;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          IntroArt(
            image: slide.image,
            tagLeft: slide.tagLeft,
            tagRight: slide.tagRight,
          ),
          // The copy must clear the photo circle and the lower floating tag,
          // which hangs below the circle's edge.
          const SizedBox(height: 34),
          Text(
            slide.eyebrow,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: HFColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              text: '${slide.headline}\n',
              children: [
                TextSpan(
                  text: slide.headlineAccent,
                  style: AppTheme.display(34, color: HFColors.primary),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppTheme.display(34),
          ),
          const SizedBox(height: 13),
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.8,
              color: Color(0xFF75695E),
            ),
          ),
        ],
      ),
    );
  }
}
