import 'package:flutter/material.dart';

/// Design tokens for font_lens inspector panel and overlays.
class FontLensTokens {
  const FontLensTokens({
    required this.surface,
    required this.raised,
    required this.ink,
    required this.inkMuted,
    required this.hairline,
    required this.accent,
    required this.warn,
  });

  /// Panel background
  final Color surface;

  /// Rows, cards, elevated elements
  final Color raised;

  /// Primary text color
  final Color ink;

  /// Secondary text color
  final Color inkMuted;

  /// Dividers, hairline borders
  final Color hairline;

  /// Selection, highlights, active chips, action buttons
  final Color accent;

  /// Warnings
  final Color warn;

  /// Light theme token set
  static const light = FontLensTokens(
    surface: Color(0xFFF4F6F8),
    raised: Color(0xFFFFFFFF),
    ink: Color(0xFF12161C),
    inkMuted: Color(0xFF5B6572),
    hairline: Color(0xFFDDE2E8),
    accent: Color(0xFFD6006B),
    warn: Color(0xFFB25E00),
  );

  /// Dark theme token set
  static const dark = FontLensTokens(
    surface: Color(0xFF14171C),
    raised: Color(0xFF1D2127),
    ink: Color(0xFFECEFF3),
    inkMuted: Color(0xFF98A1AD),
    hairline: Color(0xFF2B313A),
    accent: Color(0xFFFF4D9D),
    warn: Color(0xFFFFB84D),
  );

  /// Helper to get light or dark tokens based on brightness
  static FontLensTokens of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
