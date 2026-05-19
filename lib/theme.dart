import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Palette ──────────────────────────────────────────────────────────────────

class SrcColors {
  // Light
  static const bg = Color(0xFFFAF6EF);
  static const bgGrain = Color(0xFFF5EFE2);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF3EDE0);
  static const surface3 = Color(0xFFE9E2D2);
  static const ink = Color(0xFF1A1814);
  static const ink2 = Color(0xFF3A342C);
  static const inkSoft = Color(0xFF6E6657);
  static const inkFaint = Color(0xFF9B9384);
  static const border = Color(0x14141208);
  static const borderStrong = Color(0x241A1814);
  static const hover = Color(0x0A1A1814);

  // Dark
  static const bgDark = Color(0xFF14130F);
  static const bgGrainDark = Color(0xFF1A1814);
  static const surfaceDark = Color(0xFF1F1D18);
  static const surface2Dark = Color(0xFF2A2722);
  static const surface3Dark = Color(0xFF38342D);
  static const inkDark = Color(0xFFF2EDE3);
  static const ink2Dark = Color(0xFFD9D2C2);
  static const inkSoftDark = Color(0xFFA39B8C);
  static const inkFaintDark = Color(0xFF6E6657);
  static const borderDark = Color(0x14F2EDE3);
  static const borderStrongDark = Color(0x29F2EDE3);

  // Accent — terracotta
  static const accent = Color(0xFFC66A4D);
  static const accentInk = Color(0xFFFFFFFF);

  // Semantic
  static const ok = Color(0xFF5A8A4A);
  static const warn = Color(0xFFC79A3E);
  static const err = Color(0xFFB5443A);
  static const info = Color(0xFF4B6CA8);

  // File thumb gradients
  static const thumbImg = [Color(0xFF6B7A3B), Color(0xFF97A25B)];
  static const thumbDoc = [Color(0xFF4B6CA8), Color(0xFF6E8DC7)];
  static const thumbPdf = [Color(0xFFB5443A), Color(0xFFD96A5E)];
  static const thumbVid = [Color(0xFF8E4D7A), Color(0xFFB375A0)];
  static const thumbAud = [Color(0xFFC79A3E), Color(0xFFE0B85E)];
  static const thumbZip = [Color(0xFF5B544A), Color(0xFF8A8276)];
  static const thumbCode = [Color(0xFF1A1814), Color(0xFF3A342C)];
}

// ── Theme ────────────────────────────────────────────────────────────────────

ThemeData buildTheme(bool dark) {
  final bg = dark ? SrcColors.bgDark : SrcColors.bg;
  final surface = dark ? SrcColors.surfaceDark : SrcColors.surface;
  final ink = dark ? SrcColors.inkDark : SrcColors.ink;
  final border = dark ? SrcColors.borderDark : SrcColors.border;

  final base = GoogleFonts.nunitoSansTextTheme();

  return ThemeData(
    brightness: dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: SrcColors.accent,
      onPrimary: SrcColors.accentInk,
      secondary: SrcColors.accent,
      onSecondary: SrcColors.accentInk,
      error: SrcColors.err,
      onError: Colors.white,
      surface: surface,
      onSurface: ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerColor: border,
    textTheme: GoogleFonts.nunitoSansTextTheme(base).copyWith(
      bodyLarge: GoogleFonts.nunitoSans(fontSize: 14, color: ink),
      bodyMedium: GoogleFonts.nunitoSans(fontSize: 13, color: ink),
      bodySmall: GoogleFonts.nunitoSans(fontSize: 11.5, color: dark ? SrcColors.inkSoftDark : SrcColors.inkSoft),
      titleMedium: GoogleFonts.nunitoSans(fontSize: 15, fontWeight: FontWeight.w600, color: ink),
      titleLarge: GoogleFonts.nunitoSans(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: ink),
    ),
  );
}

// ── Helpers ──────────────────────────────────────────────────────────────────

extension SrcTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg => isDark ? SrcColors.bgDark : SrcColors.bg;
  Color get bgGrain => isDark ? SrcColors.bgGrainDark : SrcColors.bgGrain;
  Color get surface => isDark ? SrcColors.surfaceDark : SrcColors.surface;
  Color get surface2 => isDark ? SrcColors.surface2Dark : SrcColors.surface2;
  Color get surface3 => isDark ? SrcColors.surface3Dark : SrcColors.surface3;
  Color get ink => isDark ? SrcColors.inkDark : SrcColors.ink;
  Color get ink2 => isDark ? SrcColors.ink2Dark : SrcColors.ink2;
  Color get inkSoft => isDark ? SrcColors.inkSoftDark : SrcColors.inkSoft;
  Color get inkFaint => isDark ? SrcColors.inkFaintDark : SrcColors.inkFaint;
  Color get borderColor => isDark ? SrcColors.borderDark : SrcColors.border;
  Color get borderStrong => isDark ? SrcColors.borderStrongDark : SrcColors.borderStrong;
  Color get accentSoft => SrcColors.accent.withOpacity(isDark ? 0.18 : 0.12);
  Color get accentSoft2 => SrcColors.accent.withOpacity(isDark ? 0.28 : 0.20);
}
