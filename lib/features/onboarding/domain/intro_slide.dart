import 'package:flutter/foundation.dart';

/// One page of the intro carousel — pages 02 to 05 of the HTML pack, which
/// share a layout and differ only in photo, tags and copy.
@immutable
class IntroSlide {
  const IntroSlide({
    required this.image,
    required this.tagLeft,
    required this.tagRight,
    required this.eyebrow,
    required this.headline,
    required this.headlineAccent,
    required this.description,
  });

  final String image;
  final String tagLeft;
  final String tagRight;
  final String eyebrow;

  /// The ink-coloured half of the Anton heading.
  final String headline;

  /// The orange half, on its own line.
  final String headlineAccent;
  final String description;

  static const all = <IntroSlide>[
    IntroSlide(
      image: 'assets/images/onboarding_1.png',
      tagLeft: 'YOUR FITNESS BUSINESS',
      tagRight: 'Ready to grow',
      eyebrow: 'WELCOME TO HELLOFIT',
      headline: 'TRAIN MORE.',
      headlineAccent: 'GROW FASTER.',
      description:
          'Your coaching journey starts here. Manage sessions, connect with '
          'clients and build your fitness business — all in one place.',
    ),
    IntroSlide(
      image: 'assets/images/onboarding_2.jpg',
      tagLeft: 'MANAGE CLIENTS',
      tagRight: 'TRACK SESSIONS',
      eyebrow: 'WELCOME TO HELLOFIT',
      headline: 'MANAGE. TRAIN.',
      headlineAccent: 'GROW.',
      description:
          'A complete platform for fitness trainers to manage clients, '
          'sessions, workouts and earnings — all in one place.',
    ),
    IntroSlide(
      image: 'assets/images/onboarding_3.jpg',
      tagLeft: 'MANAGE CLIENTS',
      tagRight: 'TRACK PROGRESS',
      eyebrow: 'MANAGE YOUR CLIENTS',
      headline: 'BUILD STRONGER',
      headlineAccent: 'CLIENT RELATIONSHIPS.',
      description:
          'Keep all your clients in one place, track their goals, progress, '
          'and fitness journey effortlessly.',
    ),
    IntroSlide(
      image: 'assets/images/onboarding_4.jpg',
      tagLeft: 'GET MORE BOOKINGS',
      tagRight: 'GROW YOUR EARNINGS',
      eyebrow: 'GROW YOUR FITNESS BUSINESS',
      headline: 'TAKE YOUR TRAINING BUSINESS',
      headlineAccent: 'TO THE NEXT LEVEL.',
      description:
          'Get more clients, manage your schedule, boost your earnings, and '
          'grow your fitness brand with HelloFit.',
    ),
  ];
}
