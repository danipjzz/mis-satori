// lib/theme/colors.dart
import 'package:flutter/material.dart';

class SatoriColors {
  // 🌸 Rosas
  static const Color pinkPrimary = Color(0xFFF4879A);
  static const Color pinkLight   = Color(0xFFFADADD);
  static const Color pinkPale    = Color(0xFFFFF0F3);
  static const Color pinkDeep    = Color(0xFFE05D75);

  // 🩵 Teales / Mint
  static const Color teal        = Color(0xFF5ECECE);
  static const Color tealDark    = Color(0xFF3AACAC);
  static const Color tealLight   = Color(0xFFA8ECEC);
  static const Color tealPale    = Color(0xFFE8FAFA);

  // ☀️ Amarillos
  static const Color yellow      = Color(0xFFFFD166);
  static const Color yellowLight = Color(0xFFFFF3CC);

  // 🌿 Verdes
  static const Color green       = Color(0xFFA8D8A8);
  static const Color greenDark   = Color(0xFF5A9E5A);

  // ⬛ Neutros
  static const Color white       = Color(0xFFFFFFFF);
  static const Color offWhite    = Color(0xFFFDFCFD);
  static const Color textDark    = Color(0xFF3D2B1F);
  static const Color textMid     = Color(0xFF7A5C52);
  static const Color textLight   = Color(0xFFB89FA0);

  // 🔵 Ring Colors (BackgroundCircles variants)
  static const Color emerald     = Color(0xFF10B981); // primary ring 0
  static const Color cyanRing    = Color(0xFF22D3EE); // primary ring 1
  static const Color violetRing  = Color(0xFF8B5CF6); // secondary ring 0
  static const Color fuchsiaRing = Color(0xFFD946EF); // secondary ring 1
  static const Color roseRing    = Color(0xFFF43F5E); // octonary/quinary ring
}

class SatoriTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SatoriColors.pinkPrimary,
      primary:   SatoriColors.pinkPrimary,
      secondary: SatoriColors.teal,
    ),
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: SatoriColors.pinkPale,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: SatoriColors.textDark,
    ),
  );
}
