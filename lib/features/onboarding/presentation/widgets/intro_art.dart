import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';

/// `.art` — dashed orbit, round photo, two floating tags.
class IntroArt extends StatelessWidget {
  const IntroArt({
    super.key,
    required this.image,
    required this.tagLeft,
    required this.tagRight,
  });

  final String image;
  final String tagLeft;
  final String tagRight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.314,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: HFColors.primary.withAlpha(0x60),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEADDCF),
              border: Border.all(color: HFColors.soft, width: 10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x265B3D24),
                  blurRadius: 35,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.6),
              ),
            ),
          ),
          Positioned(left: 0, top: 60, child: _FloatTag(label: tagLeft)),
          Positioned(
            right: 0,
            bottom: 40,
            child: _FloatTag(label: tagRight, dot: true),
          ),
        ],
      ),
    );
  }
}

/// `.float-tag`
class _FloatTag extends StatelessWidget {
  const _FloatTag({required this.label, this.dot = false});

  final String label;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: HFColors.white,
        border: Border.all(color: HFColors.taupe.withAlpha(0x73)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14362517),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 7),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF46A36B),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 7),
              child: Text('✦', style: TextStyle(fontSize: 10)),
            ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: HFColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
