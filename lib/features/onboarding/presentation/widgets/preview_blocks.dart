import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/widgets/hf_card.dart';
import '../../../profile/domain/instructor_profile.dart';

/// The read-only blocks of page 23 — identity card, facts table, chip rows.

class PreviewIdentity extends StatelessWidget {
  const PreviewIdentity({super.key, required this.profile});

  final InstructorProfile profile;

  @override
  Widget build(BuildContext context) {
    final initials = profile.name.isEmpty
        ? '?'
        : profile.name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join();

    return HFCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: HFColors.avatarBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: HFColors.avatarInk,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.onboarding.isApproved
                      ? 'Verified trainer'
                      : 'Submitted for review',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF75695E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewFacts extends StatelessWidget {
  const PreviewFacts({super.key, required this.profile});

  final InstructorProfile profile;

  @override
  Widget build(BuildContext context) {
    return HFCard(
      child: Column(
        children: [
          _Row(label: 'Experience', value: '${profile.experienceYears}+ years'),
          if (profile.travelRadiusKm != null)
            _Row(label: 'Travels up to', value: '${profile.travelRadiusKm} km'),
          if ((profile.bio ?? '').isNotEmpty)
            _Row(label: 'About', value: profile.bio!),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF75695E)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewChips extends StatelessWidget {
  const PreviewChips({super.key, required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: HFColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final value in values)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: HFColors.soft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
