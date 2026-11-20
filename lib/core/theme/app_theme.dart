import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Material theme built from [HFColors] so no screen hard-codes a colour.
abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final text = GoogleFonts.poppinsTextTheme(
      base.textTheme,
    ).apply(bodyColor: HFColors.ink, displayColor: HFColors.ink);

    return base.copyWith(
      scaffoldBackgroundColor: HFColors.ivory,
      colorScheme: base.colorScheme.copyWith(
        primary: HFColors.primary,
        surface: HFColors.white,
        onSurface: HFColors.ink,
        error: HFColors.primary,
      ),
      textTheme: text,
      dividerColor: HFColors.line,
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Anton display face — the `.name` heading and other big type.
  static TextStyle display(double size, {Color? color}) => GoogleFonts.anton(
    fontSize: size,
    letterSpacing: .3,
    height: 1.15,
    color: color ?? HFColors.ink,
  );
}
