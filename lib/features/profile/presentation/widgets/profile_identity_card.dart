import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../domain/instructor_profile.dart';

/// `.profile` on page 65 — the dark card at the top of Profile & settings:
/// initials tile, name, one line of role, and the verification pill.
class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({super.key, required this.profile});

  final InstructorProfile profile;

  /// "Tejas Joshi" → "TJ". One letter when there is only one word.
  String get _initials {
    final words = profile.name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    final first = words.first[0];
    final last = words.length > 1 && words.last.isNotEmpty ? words.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// The design reads "Certified Personal Trainer · Pune". Both halves are
  /// optional, so the separator only appears when both are there.
  String get _role {
    final parts = [
      profile.contact.qualification ?? profile.specialisations.firstOrNull,
      profile.contact.city,
    ].whereType<String>().where((p) => p.trim().isNotEmpty);
    return parts.isEmpty ? 'Trainer' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final stage = profile.onboarding.stage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HFColors.ink,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF4D9C9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              _initials,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF99442F),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.trim().isEmpty ? 'Your profile' : profile.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _role,
                  style: const TextStyle(fontSize: 9, color: Color(0xFFE8D9CD)),
                ),
                const SizedBox(height: 7),
                _StagePill(stage: stage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `.verified` on page 65, widened to carry the other stages — a trainer in
/// review must be able to read their own status here, not only on the home
/// banner.
class _StagePill extends StatelessWidget {
  const _StagePill({required this.stage});

  final String stage;

  static const _labels = {
    'APPLIED': 'Application not submitted',
    'DOCUMENTS_SUBMITTED': 'In review',
    'SCREENING_CALL': 'Screening call',
    'DEMO_SESSION': 'Demo session',
    'APPROVED': '✓ Verified Trainer',
    'REJECTED': 'Application rejected',
  };

  @override
  Widget build(BuildContext context) {
    final approved = stage == 'APPROVED';
    final rejected = stage == 'REJECTED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: approved
            ? const Color(0xFF254C3B)
            : rejected
            ? const Color(0xFF5A2A22)
            : const Color(0xFF3A342E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _labels[stage] ?? stage,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: approved
              ? const Color(0xFFC9F1D8)
              : rejected
              ? const Color(0xFFF4C9B9)
              : const Color(0xFFE8D9CD),
        ),
      ),
    );
  }
}
