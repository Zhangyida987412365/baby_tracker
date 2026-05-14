import 'package:flutter/material.dart';

class AppStyles {
  // ── Colors ──────────────────────────────
  static const Color bgApp    = Color(0xFFFCF5F5);  // Apple-like warm cream white
  static const Color bgCard   = Color(0x99FFFFFF);  // rgba(255,255,255,0.6) - more transparent glass
  static const Color bgSoft   = Color(0x66FFFFFF);  // rgba(255,255,255,0.4)
  static const Color bgPill   = Color(0xB3FFFFFF);  // rgba(255,255,255,0.7)

  // Typography - Premium deep warm plum/browns
  static const Color ink      = Color(0xFF3A2A2D);
  static const Color ink2     = Color(0xFF8E7C80);
  static const Color ink3     = Color(0xFFBDB0B4);
  static const Color ink4     = Color(0xFFE8DFE1);

  static const Color line     = Color(0xB3FFFFFF);
  static const Color line2    = Color(0x66FFFFFF);

  // Brand - Meiyou core elegant coral rose
  static const Color brand    = Color(0xFFFF5A79);

  // Category Colors - Pastel neon glass
  static const Color cMilk    = Color(0xFFFF6482);
  static const Color cMilk2   = Color(0x1FFF6482);  
  static const Color cSleep   = Color(0xFF5E9FFF);
  static const Color cSleep2  = Color(0x1F5E9FFF);
  static const Color cDiaper  = Color(0xFFFFB03A);
  static const Color cDiaper2 = Color(0x1FFFB03A);
  static const Color cGrowth  = Color(0xFF2FD19D);
  static const Color cGrowth2 = Color(0x1F2FD19D);
  static const Color cCare    = Color(0xFF9B6BFF);
  static const Color cCare2   = Color(0x1F9B6BFF);
  static const Color cWater   = Color(0xFF44C9FF);
  static const Color cFood    = Color(0xFFFF884D);

  // ── Shadows ──────────────────────────────
  static List<BoxShadow> get shadowCard => [
    BoxShadow(color: const Color(0x40DCA0B4), blurRadius: 36, offset: const Offset(0, 12)),
    BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 1, offset: const Offset(0, 1), spreadRadius: 0),
  ];

  static List<BoxShadow> get shadowPop => [
    BoxShadow(color: const Color(0x66FF5A79), blurRadius: 40, offset: const Offset(0, 16)),
    BoxShadow(color: const Color(0x33FF5A79), blurRadius: 12, offset: const Offset(0, 4)),
  ];

  // ── Border radius ─────────────────────────
  static const double rSm = 16.0;
  static const double rMd = 22.0;
  static const double rLg = 32.0;
  static const double rXl = 40.0;

  // ── Background gradient ──────────────────
  static BoxDecoration get appBackground => const BoxDecoration(
    color: bgApp,
    gradient: RadialGradient(
      center: Alignment(-1.0, -1.0),
      radius: 1.2,
      colors: [Color(0x99FFB4C8), Color(0x00FFB4C8)],
    ),
  );

  // ── Text styles ──────────────────────────
  static const TextStyle serif = TextStyle(
    fontFamily: 'Quicksand',
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
