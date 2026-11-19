import 'package:flutter/material.dart';

/// Design tokens transcribed 1:1 from the client's trainer-app HTML pack
/// (`Trainer app screen/`, page 24 `:root`). Do not invent values here — every
/// colour below appears in that CSS.
abstract final class HFColors {
  // :root vars
  static const ivory = Color(0xFFFFF6EC);
  static const primary = Color(0xFFE33E29);
  static const taupe = Color(0xFFC1B19E);
  static const ink = Color(0xFF161614);
  static const soft = Color(0xFFF3EAE0);
  static const white = Color(0xFFFFF9F2);
  static const muted = Color(0xFF82796F);
  static const line = Color(0xFFEADFD3);

  // Status banner
  static const statusBg = Color(0xFFFFF0E8);
  static const statusBorder = Color(0xFFF4C9B9);
  static const statusTitle = Color(0xFF973C2A);
  static const statusBody = Color(0xFF94685C);
  static const statusTag = Color(0xFFA33D2B);

  // Cards
  static const metricCaption = Color(0xFF81766B);
  static const avatarBg = Color(0xFFE8D4C2);
  static const avatarInk = Color(0xFF805640);
  static const navIdle = Color(0xFF887D72);

  static const cardShadow = Color(0x2533251C);
}

/// Corner radii, straight off the CSS.
abstract final class HFRadius {
  static const iconButton = 12.0;
  static const status = 13.0;
  static const metric = 15.0;
  static const card = 16.0;
  static const time = 11.0;
  static const symbol = 8.0;
  static const quick = 13.0;
  static const pill = 20.0;
  static const phone = 34.0;
}

/// Font families. Anton for display, Poppins for UI text — spec 5.9 and the
/// HTML pack both say so.
abstract final class HFFonts {
  static const display = 'Anton';
  static const body = 'Poppins';
}
