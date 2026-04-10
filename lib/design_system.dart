import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignSystem {
  // Brand Palette (Premium Deep Navy & Vibrant Cyan)
  static const Color primary = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFF38BDF8);  // Sky 400 (Vibrant Action)
  static const Color secondary = Color(0xFF10B981); // Emerald (Success/Income)
  static const Color tertiary = Color(0xFFEF4444);  // Red (Danger/Expense)
  
  static const Color income = secondary;
  static const Color expense = tertiary;

  // Backgrounds & Surfaces
  static const Color background = Color(0xF8FAFCFF); // Slate 50
  static const Color backgroundSoft = background;
  static const Color surface = Colors.white;
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color cardBg = Colors.white;
  
  // Neutral Tones
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textWhite = Colors.white;
  static const Color outline = Color(0xFFE2E8F0); // Slate 200
  static const Color outlineVariant = Color(0xFFF1F5F9); // Slate 100

  // Gradients
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = premiumGradient;

  static const LinearGradient softBackgroundGradient = LinearGradient(
    colors: [background, Color(0xFFF1F5F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Borders & Shadows
  static final BorderRadius borderRadius = BorderRadius.circular(16);
  static final BorderRadius cardBorderRadius = BorderRadius.circular(24);
  
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> ambientShadow = softShadow;
  static const List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 40,
      offset: Offset(0, 20),
    ),
  ];

  // Typography
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -1.0,
  );

  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle headlineSmall = displayMedium;
  static TextStyle heading2 = displayMedium;

  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );
}
